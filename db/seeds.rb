require 'json'
require 'open-uri'
require 'nokogiri'

##############################################################

# # Definindo o range de anos do seed
years_array = (2012..2018).to_a

##############################################################
# # Puxando Vereadores (Somente com o nome e chave. Ainda falta definir os partidos)

# Councillor.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!('councillors')

# puts "Parsing councillors..."

# url = 'http://splegisws.camara.sp.gov.br/ws/ws2.asmx/VereadoresJSON'
# vereadores_serialized = open(url).read
# vereadores = JSON.parse(vereadores_serialized)

# vereadores.each do |vereador|
#   councillor = Councillor.create!(name: vereador["nome"], chave: vereador["chave"])
# end


# puts "Done with Councillors!"

# ##############################################################
# # Puxando Attendance

# # Attendance.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('attendances')

# puts "Parsing attendance..."

# years_array.each do |year|
#   puts "...from year #{year}..."
#   document = Nokogiri::XML(open("https://splegispdarmazenamento.blob.core.windows.net/containersip/PRESENCAS_#{year}.xml"))
#   document.xpath('/CMSP/Vereador').each do |vereador|
#     chave_vereador = vereador['IDParlamentar'].to_i
#     councillor = Councillor.find_by(chave: chave_vereador)
#     partido = vereador['Partido']
#     vereador.css('Sessao').each do |sessao|
#       data = Date.parse(sessao['Dia'])
#       sessao['Presenca'] == "Presente" ? presente = true : presente = false
#       Attendance.create!(councillor_id: councillor.id, att_date: data, present: presente, party: partido)
#     end
#   end
#   puts "Done parsing attendances from #{year}."
# end

# puts "Done with Attendances!"

# # ##############################################################
# # # Puxando o partido que cada vereador representou na sua ultima votacao

# puts "Assigning councillors parties..."

# Councillor.all.each do |vereador|
#   last_att = Attendance.where(councillor_id: vereador.id).last
#   vereador.party = last_att.party if last_att.nil? == false
#   vereador.save
# end

# puts "Done!"

# ##############################################################
# # Puxando Projetos de 2012 a 2018 e as Autorias de cada um deles

# # Project.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('projects')
# # Authorship.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('authorships')

# puts "Parsing projects..."

# years_array.each do |year|

#   puts "...from year #{year}..."

#   url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosPorAnoJSON?ano=#{year}"
#   projetos_serialized = open(url).read
#   projetos = JSON.parse(projetos_serialized)
#   projetos.each do |projeto|
#     numero = projeto["numero"]
#     tipo = projeto["tipo"]
#     ano = projeto["ano"]

#     project = Project.new(
#       chave: projeto["chave"],
#       numero: numero,
#       tipo: tipo,
#       ano: ano,
#       ementa: projeto["ementa"],
#       status: "",
#       )
#     project.save

#     url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosAutoresJSON?ano=#{ano}&tipo=#{tipo}&numero=#{numero}"
#     autores_serialized = open(url).read
#     autores = JSON.parse(autores_serialized)

#     autores[0]["autores"].each do |autor|
#       vereador = Councillor.find_by(chave: autor['chave'])
#       Authorship.create!(project_id: project[:id], councillor_id: vereador[:id])
#     end

#   end
#   puts "Done parsing #{year}"

# end

# puts "Done parsing projects!"

##############################################################
# # Puxando votaçoes

Voting.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('votings')

puts "Parsing votings..."

years_array.each do |year|
  puts "...from year #{year}..."

  document  = Nokogiri::XML(open("https://splegispdarmazenamento.blob.core.windows.net/containersip/VOTACOES_#{year}.xml"))
  document.xpath('/CMSP/Sessao').each do |sessao|
    data =  Date.parse(sessao['Data'])
    session_name = sessao['Nome']
    sessao.css('Votacao').each do |votacao|
      tipo = votacao['TipoVotacao']
      ementa = votacao['Ementa']
      rodape = votacao['NotasRodape']
      materia = votacao['Materia']
      chave = votacao['VotacaoID'].to_i

      if votacao['Resultado'] = "Aprovado1"
        resultado = "Aprovado"
      else
        resultado = votacao['Resultado']
      end

      # p materia.scan(/[A-Z]+\s\d+\s?\/\d+/).empty?
      if materia.scan(/[A-Z]+\s\d+\s?\/\d+/).empty? == false
        array = materia.scan(/[A-Z]+\s\d+\s?\/\d+/).first.split(' ')
        tipo_projeto = array[0]
        if array.length == 2
          num_ano = array[1].scan(/\d+\s?\/\d+/)[0].split('/')
        elsif array.length == 3
          num_ano = [array[1], array[2].scan(/\d+/).first]
        end
      else
        tipo_projeto = nil
        num_ano = ["0", "0"]
      end

      project = Project.find_by(numero: num_ano[0].to_i, ano: num_ano[1].to_i, tipo: tipo_projeto )

      if project.nil? == false
        project_id = project.id
        partido = project.authorships.first.councillor.party
        if tipo == "Nominal"
          votacao.css("Vereador").each do |vereador|
            councillor_id = Councillor.find_by(chave: vereador['IDParlamentar'].to_i).id

            vote = vereador['Voto'] == 'Sim'

            Voting.create!(
              vote_date: data,
              councillor_id: councillor_id,
              project_id: project_id,
              vote: vote,
              sessao: session_name,
              tipo: tipo,
              materia: materia,
              ementa: ementa,
              rodape: rodape,
              partido: partido,
              resultado: resultado,
              chave: chave
            )
          end
        elsif tipo == "Simbólica"
          if votacao.css("VotoContrario").empty?
            # p "simbolica"
            Voting.create!(
              vote_date: data,
              project_id: project_id,
              sessao: session_name,
              tipo: tipo,
              materia: materia,
              ementa: ementa,
              rodape: rodape,
              partido: partido,
              resultado: resultado,
              chave: chave
            )
          else
            votacao.css("VotoContrario").each do |vereador|
              unless vereador["Partido_Vereador"] == "PSDB" || vereador["Partido_Vereador"] == "PSOL" || vereador["Partido_Vereador"] == "PT"
                counc_name = vereador["Partido_Vereador"].split(" - ")[0].upcase

                # EXCEÇÕES
                counc_name = "JOSE AMERICO" if counc_name == "José Américo".upcase
                counc_name = "MARCO AURELIO CUNHA" if counc_name == "Marco Aurélio Cunha".upcase
                counc_name = "MARIO COVAS NETO" if counc_name == "Mário Covas Neto".upcase
                counc_name = "AURÉLIO NOMURA" if counc_name == "Aurelio Nomura".upcase
                counc_name = "JANAÍNA LIMA" if counc_name == "Janaina Lima".upcase
                counc_name = "ATÍLIO FRANCISCO" if counc_name == "Atilio Francisco".upcase

                p counc_name
                p data
                councillor_id = Councillor.find_by(name: counc_name).id
                p councillor_id
                vote = false
                Voting.create!(
                vote_date: data,
                councillor_id: councillor_id,
                project_id: project_id,
                vote: vote,
                sessao: session_name,
                tipo: tipo,
                materia: materia,
                ementa: ementa,
                rodape: rodape,
                partido: partido,
                resultado: resultado,
                chave: chave
                )
              end
            end
          end
        end
      end
    end
  end
  puts "Done parsing #{year}"
end

puts "Done parsing votings!"


# # # Definindo os partidos dos ultimos prefeitos de São Paulo

# define_mayors("GILBERTO KASSAB", "PSD")
# define_mayors("FERNANDO HADDAD", "PT")
# define_mayors("João Agripino da Costa Doria Junior", "PSDB")
# define_mayors("BRUNO COVAS", "PSDB")

# # # Fórmula para definir os prefeitos de São Paulo

# def define_mayors(mayor_name, mayor_party)
#   mayor = Councillor.find_by(name: mayor_name)
#   mayor.party = mayor_party
#   mayor.save
#   Voting.where(partido: nil).each do |voting|
#     if voting.project.authorships.first.councillor == mayor
#       voting.partido = mayor.party
#       voting.save
#     end
#   end
# end

##############################################################

# # Puxando Status de cada Projeto de cada Councillor

# puts "Parsing Project Status..."

# Project.update_all("status = ''");

# # Projetos em Tramitação

# Councillor.where.not(party: nil).each do |vereador|

#   url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosEmTramitacaoPorPromoventeJSON?codigo=#{vereador.chave}"
#   projetos_serialized = open(url).read
#   projetos = JSON.parse(projetos_serialized)
#   projetos.each do |projeto|
#     if projeto["ano"] >= 2012
#       project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
#                             projeto["tipo"], projeto["ano"], projeto["numero"])
#       project.status = "Em Tramitação"
#       project.save
#     end
#   end

# # Projetos Aprovados

#   url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/LeisAprovadasPorPromoventeJSON?codigo=#{vereador.chave}"
#   projetos_serialized = open(url).read
#   projetos = JSON.parse(projetos_serialized)
#   projetos.each do |projeto|
#     if projeto["projeto"]["ano"] >= 2012
#       project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
#                             projeto["projeto"]["tipo"], projeto["projeto"]["ano"], projeto["projeto"]["numero"])

#       project.status = "Aprovado"
#       project.save
#     end
#   end

# # Projetos Vetados

#   url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosVetadosPorPromoventeJSON?codigo=#{vereador.chave}"
#   projetos_serialized = open(url).read
#   projetos = JSON.parse(projetos_serialized)
#   projetos.each do |projeto|
#     if projeto["ano"] >= 2012
#       project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
#                             projeto["tipo"], projeto["ano"], projeto["numero"])

#       project.status = "Vetado"
#       project.save
#     end
#   end
# end

# counter_new_status = 0
# counter_update_status = 0
# array = []

# # Projetos Encerrados

# years_array.each do |year|
#   url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosEncerradosJSON?ano=#{year}"
#   projetos_serialized = open(url).read
#   projetos = JSON.parse(projetos_serialized)
#   projetos.each do |projeto|
#     project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
#                           projeto["tipo"], projeto["ano"], projeto["numero"])

#     case projeto["motivo"]
#     when "TERMINO DE LEGISLATURA (ART. 275 REG. INT.)"
#       project.status = "Encerrado por Término de Legislatura"
#     when "Encerrado-ILEGALIDADE (ART. 79 REG. INT.)"
#       project.status = "Encerrado por Ilegalidade"
#     when "Encerrado-RETIRADO PELO AUTOR"
#       project.status = "Retirado pelo autor"
#     when "Encerrado-PROMULGADO"
#       project.status = "Promulgado"
#     end
#     project.save
#   end
# end

##############################################################

puts "Database ready for use! =)"

##############################################################
##############################################################
# Testes
