#http://blog.caelum.com.br/screencast-ruby-on-rails-introducao-a-rspec-e-cucumber/
require 'mechanize'

class Dividendo #< ActiveRecord::Base
	def Dividendo.simbolos
		simbolos = [:papel, :data, :valor, :tipo, :por_quant_acoes]
	end
	def initialize(dividendo)
		@papel = dividendo[:papel]
		@data = dividendo[:data]
		@valor = dividendo[:valor]
		@tipo = dividendo[:tipo]
		@por_quant_acoes = dividendo[:por_quant_acoes]
	end
	def save
		puts "#{@papel}, #{@data}, #{@valor}, #{@tipo}, #{@por_quant_acoes}" 
	end
end

class Dividendos
	def initialize
		@agent = Mechanize.new
  	end
	def obter_simbolos
		initialize
		page = @agent.get('http://www.fundamentus.com.br/buscaavancada.php')
		page_form = page.form('formbusca')
		page_form.divy_min = 0
		page_form.divy_max = 100
		page_res = @agent.submit(page_form, page_form.buttons.first)
		#i = 0
		simbolos = []
		#page_res.search("//table[@id='resultado']").search('td/text()').each do |cel|
		page_res.search("//table[@id='resultado']").search("td[@ckass='res_papel']").each do |cel|
			#if i % 19 == 0
				#puts "%%%%%%%%%%%% #{cel.text}"
				simbolos << cel.text
			#end
			#i += 1
		end
		#simbolos = ['ILMD4', 'BAHI3', 'MEND6']
		simbolos
	end

	def todos_dividendos(simbolos)
		simbolos.each do |papel|
			obter_dividendos(papel)
		end
	end
  
	def obter_dividendos(papel)
		page = @agent.get('http://fundamentus.com.br/proventos.php?papel=' + papel + '&tipo=2')
		#page.search("//table[@id='resultado']/p")
		i = 0
		hash_dividendo = {}
		page.search("//table[@id='resultado']").search('td/text()').each do |cel|
			hash_dividendo[Dividendo.simbolos[i]] = cel.text
			i += 1
			if i > 3
				i = 0
				dividendo = Dividendo.new(hash_dividendo)
				dividendo.save
				hash_dividendo.clear
			end
		end    
	end
end

dividendos = Dividendos.new
todos_simbolos = dividendos.obter_simbolos
#puts todos_simbolos[0..5]
dividendos.todos_dividendos(todos_simbolos)
