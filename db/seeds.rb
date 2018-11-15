require 'json'
require 'open-uri'
require 'nokogiri'

##############################################################
# # Puxando Vereadores (Somente com o nome e chave. Ainda falta definir os partidos)

# # # Councillor.delete_all
# # # ActiveRecord::Base.connection.reset_pk_sequence!('councillors')

puts "Parsing councillors..."

url = 'http://splegisws.camara.sp.gov.br/ws/ws2.asmx/VereadoresJSON'
vereadores_serialized = open(url).read
vereadores = JSON.parse(vereadores_serialized)

vereadores.each do |vereador|
  councillor = Councillor.create!(name: vereador["nome"], chave: vereador["chave"])
end

puts "Done with Councillors!"

# ##############################################################
# # Puxando Attendance

puts "Parsing attendance..."

# [2012].each do |year|
(2012..2018).to_a.each do |year|
  puts "...from year #{year}..."
  document = Nokogiri::XML(open("https://splegispdarmazenamento.blob.core.windows.net/containersip/PRESENCAS_#{year}.xml"))
  # p "Sessoes no ano: #{document.root.xpath('/CMSP/Sessao').count}"
  # p "Votacoes no ano: #{document.root.xpath('/CMSP/Sessao/Votacao').count}"
  # p "Vereadores: #{document.root.xpath('/CMSP/Sessao/Votacao/Vereador').count}"
  document.xpath('/CMSP/Vereador').each do |vereador|
    chave_vereador = vereador['IDParlamentar'].to_i
    councillor = Councillor.find_by(chave: chave_vereador)
    partido = vereador['Partido']
    vereador.css('Sessao').each do |sessao|
      data = Date.parse(sessao['Dia'])
      sessao['Presenca'] == "Presente" ? presente = true : presente = false
    # session = Session.find_by(date: data)
    # chave_vereador = sessao['Dia'])
    # vereador = Councillor.find_by()
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

# # # Definindo os partidos dos ultimos prefeitos de São Paulo

mayor = Councillor.find_by(name: "GILBERTO KASSAB")
mayor.party = "PSD"
mayor.save
mayor = Councillor.find_by(name: "FERNANDO HADDAD")
mayor.party = "PT"
mayor.save
mayor = Councillor.find_by(name: "João Agripino da Costa Doria Junior")
mayor.party = "PSDB"
mayor.save

# puts "Done!"

# ##############################################################
# # Puxando Projetos de 2012 a 2018

# Project.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!('projects')
# Authorship.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!('authorships')

puts "Parsing projects..."

# [2012].each do |year|
(2012..2018).to_a.each do |year|

  puts "...from year #{year}..."

  url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosPorAnoJSON?ano=#{year}"
  projetos_serialized = open(url).read
  projetos = JSON.parse(projetos_serialized)
  projetos.each do |projeto|
    # projeto["ementa"].nil? ? ementa = "" : ementa = projeto["ementa"]
    numero = projeto["numero"]
    tipo = projeto["tipo"]
    ano = projeto["ano"]

    project = Project.new(
      chave: projeto["chave"],
      numero: numero,
      tipo: tipo,
      ano: ano,
      ementa: projeto["ementa"]
      )
    project.save
#     p project.id

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
# Puxando votaçoes

# Voting.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!('votings')

puts "Parsing votings..."

# [2012].each do |year|
(2012..2018).to_a.each do |year|
  puts "...from year #{year}..."

  document  = Nokogiri::XML(open("https://splegispdarmazenamento.blob.core.windows.net/containersip/VOTACOES_#{year}.xml"))
#   # p "Sessoes no ano: #{document.root.xpath('/CMSP/Sessao').count}"
#   # p "Votacoes no ano: #{document.root.xpath('/CMSP/Sessao/Votacao').count}"
#   # p "Vereadores: #{document.root.xpath('/CMSP/Sessao/Votacao/Vereador').count}"
  document.xpath('/CMSP/Sessao').each do |sessao|
    data =  Date.parse(sessao['Data'])
    session_name = sessao['Nome']
    sessao.css('Votacao').each do |votacao|
      tipo = votacao['TipoVotacao']
      ementa = votacao['Ementa']
      rodape = votacao['NotasRodape']
      materia = votacao['Materia']

      array = materia.split(' ')
      projeto_index = array.index { |e| e =~ /\d+\/\d+/ }
      if projeto_index.nil? == false
        tipo_projeto = array[projeto_index - 1]
        num_ano = array.select { |i| i[/\d+\/\d+/] }[0].split('/')
      else
        tipo_projeto = nil
        num_ano = ["0", "0"]
      end

      project = Project.find_by(numero: num_ano[0].to_i, ano: num_ano[1].to_i, tipo: tipo_projeto )

      if project.nil? == false
        project_id = project.id
        votacao.css("Vereador").each do |vereador|
          councillor_id = Councillor.find_by(chave: vereador['IDParlamentar'].to_i).id
          partido = project.authorships.first.councillor.party

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
            partido: partido
          )
        end
      end
    end
  end
  puts "Done parsing #{year}"
end

puts "Done parsing votings!"


puts "Database ready for use! =)"

##############################################################
# Testes

# materia = "PL 800/2005 - 1ª VOTAÇÃO"
# array = materia.split(' ')
# p array
# projeto_index = array.index { |e| e =~ /\d+\/\d+/ }


# materia = "SUBSTITUTIVO N.º 1 AO PL 303/2010 - 1ª VOTAÇÃO"
# array = materia.split(' ')
# p array.select { |i| i[/\d+\/\d+/] }[0]

# materia = "Adiamento do item 1:PL 71/2012"
# array = materia.split(' ')
# p array.select { |i| i[/\d+\/\d+/] }[0]

# materia = "Encerramento da Sessão"
# array = materia.split(' ')
# p array.select { |i| i[/\d+\/\d+/] }[0]

# materia = "Inversão do Item 213 para o atual item"
# array = materia.split(' ')
# p array.select { |i| i[/\d+\/\d+/] }[0]

# numero = 1
# tipo = "PL"
# ano = 2012
# url = "http://splegisws.camara.sp.gov.br/ws/ws2.asmx/ProjetosAutoresJSON?ano=#{ano}&tipo=#{tipo}&numero=#{numero}"
# autores_serialized = open(url).read
# autores = JSON.parse(autores_serialized)
# autores[0]["autores"].each do |autor|
#   puts "chave: #{autor['chave']} | nome: #{autor['nome']}"
# end

# mais_de_um = 0
# um_so = 0
# Project.all.each do |project|
#   if project.authorships.count > 1
#     mais_de_um += 1
#   else
#     um_so += 1
#   end
# end
# p mais_de_um
# p um_so

