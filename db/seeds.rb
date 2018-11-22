require 'json'
require 'open-uri'
require 'nokogiri'

##############################################################

# # Definindo o range de anos do seed
years_array = (2012..2018).to_a

# # Incluindo as fotos dos vereadores

photos = {
'2156' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/Retrato-Caio-Perfil-Facebook_ADP-1.jpg',
'776' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/Foto_Eliseu_Gabriel_portal.jpg',
'1326' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2015/03/quito-formiga-2017-1.jpg',
'160' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/eduardosuplicy2017.jpg',
'1999' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/toninho-vespoli.jpg',
'2147' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/isac_felix_2017.jpg',
'2174' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/05/amauri-direita_193_155.png',
'2151' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2016/12/ZT-6_corte_192.png',
'1930' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/ota.jpg',
'2160' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/joao_jorge_2017.jpg',
'187' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/gilson-barreto.jpg',
'224' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/aurelio-nomura.jpg',
'1707' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/Vereador_DavidSoares_2017v2.jpg',
'220' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/toninho-paiva.jpg',
'1305' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2015/03/Police_perfil.jpg',
'2145' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/fernando_holi_2017.jpg',
'1947' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/reis.jpg',
'1319' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/soninha_193_155-1.jpg',
'1636' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/DRMilton_Ferreira_2017.jpg',
'1316' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/Noemi_jum_2017.jpg',
'1634' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/Juliana-Cardoso.jpg',
'1647' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/edir_sales_2017.jpg',
'2002' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/conte-lopes.jpg',
'756' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/celso_jatene2017.jpg',
'1633' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/Vereador_SouzaSantos_2017v2.jpg',
'2152' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/rinaldi.jpg',
'676' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/atilio-francisco.jpg',
'2158' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/02/Vereador_ReginaldoTripoli_2017v2.jpg',
'2001' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/jair-tatto.jpg',
'2000' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/alessandro_guedes_2017.jpg',
'2142' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2016/12/Adriana-Ramalho-site-CMSP.jpg',
'796' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/natalini.jpg',
'268' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/dalton-silvano.jpg',
'2144' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/fabio_riva_2017.jpg',
'2159' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/rute_costa_193_155.jpg',
'155' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/arselino-tatto.jpg',
'896' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/professor_claudinho.jpg',
'1300' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/claudinho-de-souza.jpg',
'2150' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/AndreSantos_jun_2017.jpg',
'44' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/mario_covas-site.jpg',
'2154' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/camilo_cristo_2017.jpg',
'267' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/frange.jpg',
'1311' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/donato.jpg',
'1635' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/sandra_tadeu_193_155.jpg',
'1990' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/ricardo-nunes.jpg',
'2155' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/janaina_lima_2017.jpg',
'1349' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/senival-moura.jpg',
'1487' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2016/02/rteixeira_lan16-1.jpg',
'1998' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/12/Patricia-Bezerra.jpg',
'273' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/Milton_Leite_2017maio.jpg',
'1447' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/14560192_1134347556634715_1888787081855639171_o-1-1.jpg',
'1989' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2014/10/george-hato.jpg',
'1296' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/02/Vereador_AdilsonAmadeu_2017v2.jpg',
'2148' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/samia_bomfim_2017.jpg',
'2153' => 'http://www.saopaulo.sp.leg.br/wp-content/uploads/2017/01/Rodrigo_Goulart_2017.jpg'
}

##############################################################
# # Puxando Vereadores (Somente com o nome e chave. Ainda falta definir os partidos)

# # Councillor.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('councillors')

puts "Parsing councillors..."

url = 'http://splegisws.camara.sp.gov.br/ws/ws2.asmx/VereadoresJSON'
vereadores_serialized = open(url).read
vereadores = JSON.parse(vereadores_serialized)

vereadores.each do |vereador|
  councillor = Councillor.create!(name: vereador["nome"], chave: vereador["chave"])
end

Councillor.all.each do |councillor|
  councillor.photo = photos[councillor[:chave].to_s]
  councillor.save
end
puts "Done with Councillors!"

# ##############################################################
# # Puxando Attendance

# # Attendance.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('attendances')

puts "Parsing attendance..."

years_array.each do |year|
  puts "...from year #{year}..."
  document = Nokogiri::XML(open("https://splegispdarmazenamento.blob.core.windows.net/containersip/PRESENCAS_#{year}.xml"))
  document.xpath('/CMSP/Vereador').each do |vereador|
    chave_vereador = vereador['IDParlamentar'].to_i
    councillor = Councillor.find_by(chave: chave_vereador)
    partido = vereador['Partido']
    vereador.css('Sessao').each do |sessao|
      data = Date.parse(sessao['Dia'])
      sessao['Presenca'] == "Presente" ? presente = true : presente = false
      Attendance.create!(councillor_id: councillor.id, att_date: data, present: presente, party: partido)
    end
  end
  puts "Done parsing attendances from #{year}."
end

puts "Done with Attendances!"

# # ##############################################################
# # # Puxando o partido que cada vereador representou na sua ultima votacao

puts "Assigning councillors parties..."

Councillor.all.each do |vereador|
  last_att = Attendance.where(councillor_id: vereador.id).last
  vereador.party = last_att.party if last_att.nil? == false
  vereador.save
end

puts "Done!"

# ##############################################################
# # Puxando Projetos de 2012 a 2018 e as Autorias de cada um deles

# # Project.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('projects')
# # Authorship.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('authorships')

puts "Parsing projects..."

years_array.each do |year|

  puts "...from year #{year}..."

  url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosPorAnoJSON?ano=#{year}"
  projetos_serialized = open(url).read
  projetos = JSON.parse(projetos_serialized)
  projetos.each do |projeto|
    numero = projeto["numero"]
    tipo = projeto["tipo"]
    ano = projeto["ano"]

    project = Project.new(
      chave: projeto["chave"],
      numero: numero,
      tipo: tipo,
      ano: ano,
      ementa: projeto["ementa"],
      status: "",
      )
    project.save

    url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosAutoresJSON?ano=#{ano}&tipo=#{tipo}&numero=#{numero}"
    autores_serialized = open(url).read
    autores = JSON.parse(autores_serialized)

    autores[0]["autores"].each do |autor|
      vereador = Councillor.find_by(chave: autor['chave'])
      Authorship.create!(project_id: project[:id], councillor_id: vereador[:id])
    end

  end
  puts "Done parsing #{year}"

end

puts "Done parsing projects!"

##############################################################
# # Puxando votaçoes

# Voting.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!('votings')

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

      if votacao['Resultado'] == "Aprovado1" || votacao['Resultado'] == "Aprovado2"
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

                councillor_id = Councillor.find_by(name: counc_name).id
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

puts "Defining mayors and their parties..."

define_mayors("GILBERTO KASSAB", "PSD")
define_mayors("FERNANDO HADDAD", "PT")
define_mayors("João Agripino da Costa Doria Junior", "PSDB")
define_mayors("BRUNO COVAS", "PSDB")

puts "Done with mayors!"

# # # Fórmula para definir os prefeitos de São Paulo

def define_mayors(mayor_name, mayor_party)
  mayor = Councillor.find_by(name: mayor_name)
  mayor.party = mayor_party
  mayor.save
  Voting.where(partido: nil).each do |voting|
    if voting.project.authorships.first.councillor == mayor
      voting.partido = mayor.party
      voting.save
    end
  end
end

##############################################################

# # Puxando Status de cada Projeto de cada Councillor

puts "Parsing Project Status..."

# # Project.update_all("status = ''");

# # Projetos em Tramitação

puts "...first the ongoing projects..."

Councillor.where.not(party: nil).each do |vereador|

  url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosEmTramitacaoPorPromoventeJSON?codigo=#{vereador.chave}"
  projetos_serialized = open(url).read
  projetos = JSON.parse(projetos_serialized)
  projetos.each do |projeto|
    if projeto["ano"] >= 2012
      project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
                            projeto["tipo"], projeto["ano"], projeto["numero"])
      project.status = "Em Tramitação"
      project.save
    end
  end

# # Projetos Aprovados

puts "...second the approved projects..."

  url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/LeisAprovadasPorPromoventeJSON?codigo=#{vereador.chave}"
  projetos_serialized = open(url).read
  projetos = JSON.parse(projetos_serialized)
  projetos.each do |projeto|
    if projeto["projeto"]["ano"] >= 2012
      project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
                            projeto["projeto"]["tipo"], projeto["projeto"]["ano"], projeto["projeto"]["numero"])

      project.status = "Aprovado"
      project.save
    end
  end

# # Projetos Vetados

puts "...now the vetoed projects..."

  url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosVetadosPorPromoventeJSON?codigo=#{vereador.chave}"
  projetos_serialized = open(url).read
  projetos = JSON.parse(projetos_serialized)
  projetos.each do |projeto|
    if projeto["ano"] >= 2012
      project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
                            projeto["tipo"], projeto["ano"], projeto["numero"])

      project.status = "Vetado"
      project.save
    end
  end
end

# # Projetos Encerrados

puts "...and finally the closed projects..."

years_array.each do |year|
  url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosEncerradosJSON?ano=#{year}"
  projetos_serialized = open(url).read
  projetos = JSON.parse(projetos_serialized)
  projetos.each do |projeto|
    project = Project.find_by("tipo = ? AND ano = ? AND numero = ?",
                          projeto["tipo"], projeto["ano"], projeto["numero"])

    case projeto["motivo"]
    when "TERMINO DE LEGISLATURA (ART. 275 REG. INT.)"
      project.status = "Encerrado por Término de Legislatura"
    when "Encerrado-ILEGALIDADE (ART. 79 REG. INT.)"
      project.status = "Encerrado por Ilegalidade"
    when "Encerrado-RETIRADO PELO AUTOR"
      project.status = "Retirado pelo autor"
    when "Encerrado-PROMULGADO"
      project.status = "Promulgado"
    end
    project.save
  end
end

puts "...and we're done!"

##############################################################

puts "Database ready for use! =)"

##############################################################
##############################################################
# Testes
