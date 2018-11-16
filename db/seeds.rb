require 'json'
require 'open-uri'
require 'nokogiri'

##############################################################
# # Puxando Vereadores (Somente com o nome e chave. Ainda falta definir os partidos)

# Councillor.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!('councillors')

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

# # [2012].each do |year|
(2017..2018).to_a.each do |year|
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
# # Puxando Projetos de 2012 a 2018

# # Project.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('projects')
# # Authorship.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('authorships')

puts "Parsing projects..."

# # [2012].each do |year|
(2017..2018).to_a.each do |year|

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
      ementa: projeto["ementa"]
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
# Puxando votaçoes

# # Voting.delete_all
# # ActiveRecord::Base.connection.reset_pk_sequence!('votings')

puts "Parsing votings..."

# [2012].each do |year|
(2017..2018).to_a.each do |year|
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
mayor = Councillor.find_by(name: "BRUNO COVAS")
mayor.party = "PSDB"
mayor.save

Voting.where(partido: nil).all.each do |voting|
  if voting.project.authorships.first.councillor == mayor
    # count += 1
    voting.partido = mayor.party
    voting.save
    # puts "#{count} | Voting ID : #{voting.id}"
  end
end

##############################################################

puts "Database ready for use! =)"

##############################################################
##############################################################
# Testes

# array = []
# # Voting.where("vote_date BETWEEN ? AND ?", Date.parse("01 Jan 2015"), Date.parse("01 Jan 2016")).each do |voting|
# Voting.where("vote_date > ?", Date.parse("01 Jan 2017")).each do |voting|
#   councillor = voting.councillor
#   if array.include?(councillor) == false
#     array << councillor
#   end
# end
# p array.count
# # array.each do |vereador|
# #   puts "#{vereador.name} | #{vereador.party}"
# # end
