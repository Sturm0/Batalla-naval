def azulificar(cadena)
	return "\033[34m#{cadena}\033[0m"
end
azul = "\033[34m"


class Tablero
	def initialize
		#esto es la representación del tablero
		@matriz = []
		10.times { @matriz.push [0,0,0,0,0,0,0,0,0,0] }
	end
	def mostrar
		print "   "
		(1..@matriz[0].length).each {|numero| print numero," "}
		contador = 1
		print "\n#{contador}  " #esto es por el caso extremo de la primera línea
		contador += 1
		@matriz.each_with_index do |lista,indice_lista|
			
			lista.each_with_index do |elemento,indice|
				
				if indice == lista.length-1 && (indice_lista == @matriz.length-1) #caso extremo de la última línea
					puts azulificar(elemento)
				elsif indice == lista.length-1

					#bloque que se va a repetir
					if elemento == 0
						puts azulificar(elemento)
					elsif elemento == "#"
						puts "\033[90m#\033[0m"
					else
						puts elemento
					end
					#finalización del bloque repetido

					if contador >= 10
						print contador," "
					else	
						print contador,"  "
					end
					contador += 1
				else
					#bloque casi repetido
					if elemento == 0
						print azulificar(elemento)," "
					elsif elemento == "#"
						print "\033[90m#\033[0m"," "
					else
						print elemento," "
					end
					#finalización bloque casi repetido
				end
			end

		end
	puts
	end


	def poner_barco!(embarcacion,orientación,coordenadas)
		#esta función también asigna las coordenadas correspondientes a la embarcación
		#en orientación la H significa horizontal mientras que la V vertical
		#hay un problema en la colocación de barcos verticalmente en el borde izquierdo del tablero

		if orientación == "H" && coordenadas[0]+embarcacion.tamaño-1 < 10 && !(@matriz[coordenadas[1]][coordenadas[0],embarcacion.tamaño].any? {|each| each == "B" or each == "#"})
			#puts "ESTO TE INTERESA: ",coordenadas[0], embarcacion.tamaño
			
			#if embarcacion.tamaño == 1
			#	puts "MONDONGO: ",embarcacion.tamaño, orientación
			#end
			
			for each in (coordenadas[0]..coordenadas[0]+embarcacion.tamaño-1)
				if embarcacion.tamaño != 1
					@matriz[coordenadas[1]][each] = "B"
				else
					@matriz[coordenadas[1]][each] = "\033[32mB\033[0m"
				end
				embarcacion.coordenadas.push([each,coordenadas[1]])

				
			end

			for extencion in (0..embarcacion.tamaño+1)	
				#poner zona invalida: arriba
				if (coordenadas[1]-1 >= 0 and (coordenadas[0]+extencion-1 >= 0 and coordenadas[0]+extencion-1 <= 9))
					@matriz[coordenadas[1]-1][coordenadas[0]+extencion-1] = '#'
				end

				#poner zona invalida: abajo
				if (coordenadas[1]+1 <= 9 and (coordenadas[0]+extencion-1 >= 0 and coordenadas[0]+extencion-1 <= 9))
					@matriz[coordenadas[1]+1][coordenadas[0]+extencion-1] = '#'
				end
			end
			#poner zona invalida a los costados
			if coordenadas[0]-1 >= 0
				#hay un tema con el barco de 1 casillero
				@matriz[coordenadas[1]][coordenadas[0]-1] = '#'
				
			end 

			if coordenadas[0]+embarcacion.tamaño <= 9
				@matriz[coordenadas[1]][coordenadas[0]+embarcacion.tamaño] = '#'
			end	
			
			
			return true #significa que el barco se pudo colocar correctamente
		elsif orientación == "V" && coordenadas[1]+embarcacion.tamaño-1 < 10 && ((@matriz.find {|fila| fila[coordenadas[0]] == "B" or fila[coordenadas[0]] == "#"}) == nil)

			for each in (coordenadas[1]..coordenadas[1]+embarcacion.tamaño-1)
				if @matriz[each][coordenadas[0]] == "B"
					
					return false
				end
			end

			for each in (coordenadas[1]..coordenadas[1]+embarcacion.tamaño-1)
				@matriz[each][coordenadas[0]] = "B"
				embarcacion.coordenadas.push([coordenadas[0],each])
			end

			
			for extencion in (0..embarcacion.tamaño+1)
				#poner zona invalida al costado derecho
				if coordenadas[0]+1 <= 9 and coordenadas[1]+extencion-1 <= 9 and coordenadas[1]+extencion-1 >= 0
					@matriz[coordenadas[1]+extencion-1][coordenadas[0]+1] = "#"
				end

				#poner zona invalida al costado izquierdo
				for extencion in (0..embarcacion.tamaño+1)
					if coordenadas[0]-1 >= 0 and coordenadas[1]+extencion-1 <= 9 and coordenadas[1]+extencion-1 >= 0
						@matriz[coordenadas[1]+extencion-1][coordenadas[0]-1] = "#"
					end
				end
			end

			#poner arriba y abajo
			if coordenadas[1]-1 >= 0
				@matriz[coordenadas[1]-1][coordenadas[0]] = "#"
			end
			if coordenadas[1]+embarcacion.tamaño <= 9
				@matriz[coordenadas[1]+embarcacion.tamaño][coordenadas[0]] = "#"
			end

			return true
		else 
			return false
		end

		

		
	end

	def marcar_punto!(coordenadas,color)
		@matriz[coordenadas[1]][coordenadas[0]] = color+"X"+"\033[0m" #lo último es blanco, porque si no puede que la proxima impresión sea roja
	end
end

class Barco
	def initialize(tamaño_barco)
		@tamaño = tamaño_barco
		@vida = tamaño_barco
		@coordenadas = []
		@tipo = %w{lancha crucero submarino buque portaaviones}[tamaño_barco-1]
	end

	def tipo
		@tipo
	end

	def tamaño
		@tamaño
	end

	def vida
		@vida
	end

	def vida=(valor)
		@vida = valor
	end

	def coordenadas=(valor)
		@coordenadas = valor
	end

	def coordenadas
		@coordenadas
	end
end

class Jugador
	def initialize
		@barcos = []
		for each in (1..5)
			@barcos.push Barco.new(each)
		end
	end

	def barcos
		@barcos
	end

	def pedir_coordenadas()
		#le pide coordenadas al jugador
		print "Ingresar columna: "
		x = (gets.to_i) -1
		print "Ingresar coordenada fila: "
		y = (gets.to_i) -1
		return x,y
	end

	def pedir_datos()
		#le pide los datos necesarios al jugador para poner un barco
		
		x,y = pedir_coordenadas()
		print "Elegí su orientación (H: HORIZONTAL O V: VERTICAL)"
		orientación = gets.chomp
		
		return x, y,orientación
	end

	def atacar(tabla,enemigo)
		puts "¿Cuales van a ser las coordenadas de tu ataque?"
		las_coordenadas = pedir_coordenadas()		
		barco_atacado = enemigo.barcos.find {|barquito| barquito.coordenadas.any? {|coordenada_barco| coordenada_barco == las_coordenadas}} #es el barco que esta bajo ataque
		if barco_atacado != nil
			
			color = "\033[31m" #esto es el color rojo
			barco_atacado.vida -= 1
			barco_atacado.coordenadas.delete las_coordenadas #porque sino el jugador podría ganar dandole siempre a la misma coordenada 
			system("clear") || system("cls")
			if barco_atacado.vida == 0
				puts "¡¡¡¡¡¡¡LO HUNDISTE!!!!!!!!"
			else
				puts "LE DISTEEEEEEE!!!!!!!!!!!!!! MAQUINA"
			end 

		else
			system("clear") || system("cls")
			puts "F, no le pegaste a nada"
			color = ""
		end
		tabla.marcar_punto!(las_coordenadas,color)
	end
	def vivo?
		@barcos.any? {|barquito| barquito.vida > 0}
	end
end

class Bot < Jugador
	def initialize
		super
		@historial_ataques = []
		@historial_ataques_exitosos = [] #contiene un historial con los barcos atacados de forma exitosa
		@coordenadas_circundantes = [] #tiene las coordenadas circundantes a un ataque exitoso, tienen la forma x,y
		@barco_atacado = nil
	end

	def pedir_coordenadas()
		#le pide coordenadas al bot

		if @barco_atacado.class == Barco and @barco_atacado.vida <= @barco_atacado.tamaño-2 and @barco_atacado.vida > 0
			return @barco_atacado.coordenadas[0]

		elsif @coordenadas_circundantes.length > 0 and @historial_ataques_exitosos.last.vida > 0
			coordenadas_elegidas = @coordenadas_circundantes.sample
			while @historial_ataques.any? coordenadas_elegidas
				coordenadas_elegidas = @coordenadas_circundantes.sample
			end

			@coordenadas_circundantes.delete coordenadas_elegidas
			return coordenadas_elegidas
		end


		x = Random.rand(10)
		y = Random.rand(10)
		while @historial_ataques.any? [x,y]
			x = Random.rand(10)
			y = Random.rand(10)
		end 

		return x,y
	end

	def pedir_datos()
		#le pide los datos necesarios al bot para poner un barco
		return Random.rand(10),Random.rand(10),%w{H V}[Random.rand(2)]
	end

	def atacar(tabla,enemigo)
		las_coordenadas = pedir_coordenadas()
		#puts "ESTÁS SON LAS COORDENADAS DEL ATAQUE: \n","Fila: ",las_coordenadas[1]+1,"\n","Columna: ",las_coordenadas[0]+1 # por alguna razón no coincide con el tablero oceano
		@barco_atacado = enemigo.barcos.find {|barquito| barquito.coordenadas.any? {|coordenada_barco| coordenada_barco == las_coordenadas}} #es el barco que esta bajo ataque

		@historial_ataques.push las_coordenadas
		if @barco_atacado != nil

			color = "\033[31m" #esto es el color rojo
			@barco_atacado.vida -= 1
			@barco_atacado.coordenadas.delete las_coordenadas
			@historial_ataques_exitosos.push @barco_atacado

			#la sección siguiente es para determinar los casilleros circundantes al ataque exitoso
			@coordenadas_circundantes = []
			#poner zona circundante a los costados
			if las_coordenadas[0]-1 >= 0 and !(@historial_ataques.any? [las_coordenadas[0]-1,las_coordenadas[1]])
				@coordenadas_circundantes.push [las_coordenadas[0]-1,las_coordenadas[1]]
			end 

			if las_coordenadas[0]+1 <= 9 and !(@historial_ataques.any? [las_coordenadas[0]+1,las_coordenadas[1]])
				@coordenadas_circundantes.push [las_coordenadas[0]+1,las_coordenadas[1]]
			end	

			#poner arriba y abajo
			if las_coordenadas[1]-1 >= 0 and !(@historial_ataques.any? [las_coordenadas[0],las_coordenadas[1]-1])
				@coordenadas_circundantes.push [las_coordenadas[0],las_coordenadas[1]-1]
			end
			if las_coordenadas[1]+1 <= 9 and !(@historial_ataques.any? [las_coordenadas[0],las_coordenadas[1]+1])
				@coordenadas_circundantes.push [las_coordenadas[0],las_coordenadas[1]+1]
			end

			#fin de la sección para determinar los casilleros circundantes al ataque exitoso
		else
			color = ""
		end
		tabla.marcar_punto!(las_coordenadas,color)
	end
end

oceano = Tablero.new 
oceano_bot = Tablero.new #tener un oceano para el bot si bien es la forma más sencilla de hacerlo es ineficiente. En algún momento lo arreglaré
tiro = Tablero.new
el_jugador = Jugador.new
el_bot = Bot.new
tiro.mostrar
oceano.mostrar

puts "Hola JUGADOR, para empezar la partida primero debera decidir donde colocar sus barcos"
puts "Cuenta con: un portaaviones(5 casilleros), un buque (4 casilleros), un submarino (3 casilleros), un crucero (2 casillas) y una lacha (1 casillero)"
puts

#esta sección es para que el jugador ponga los barcos en su tablero oceano
puts "Empezemos colocando el portaaviones"
x,y,orientación = el_jugador.pedir_datos()
oceano.poner_barco!(el_jugador.barcos[4],orientación,[x,y])
system("clear") || system("cls")
tiro.mostrar
oceano.mostrar

for idx in (0..3).to_a.reverse!
	puts "Ahora el #{el_jugador.barcos[idx].tipo}"
	x,y,orientación = el_jugador.pedir_datos() 
	while !(oceano.poner_barco!(el_jugador.barcos[idx],orientación,[x,y])) 
		x,y,orientación = el_jugador.pedir_datos() 
	end
	
	#for each in (0..4)
	#	x,y = each,each
	#	orientación = 'H'
	#	oceano.poner_barco!(el_jugador.barcos[each],orientación,[x,y])
	#end
	
	system("clear") || system("cls")
	tiro.mostrar
	oceano.mostrar
end
#termina la sección del jugador para la colocación de barcos

#esta sección es para hacer más simple la depuración
=begin
il_tamaño = 4
for each in (0..9)
	if each%2 == 0
		x,y = each,each
		oceano.poner_barco!(el_jugador.barcos[il_tamaño],'H',[x,y])
		il_tamaño -= 1
	end
	
end
=end
#termina la sección para hacer más simple la depuración

#esta sección es para que el bot ponga sus barcos
for idx in (0..4).to_a.reverse!
	x,y,orientación = el_bot.pedir_datos()
	while !(oceano_bot.poner_barco!(el_bot.barcos[idx],orientación,[x,y]))
		x,y,orientación = el_bot.pedir_datos()
	end
	
	
end
#oceano_bot.mostrar
#print el_bot.barcos[0].coordenadas

#el_bot.barcos.each {|barcaza| print barcaza.coordenadas}
#termina la sección del bot para la colocación de barcos

puts "MUY BIEN!, ahora tenés que hundir a la flota enemiga"


while true
	el_jugador.atacar(tiro,el_bot)
	el_bot.atacar(oceano,el_jugador)
	tiro.mostrar
	oceano.mostrar
	
	if !el_bot.vivo?
		puts "¡GANASTE!"
		break
	elsif !el_jugador.vivo?
		puts "PERDISTE"
		break
	end
end
