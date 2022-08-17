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

		if orientación == "H" && coordenadas[0]+embarcacion.tamaño-1 < 10
			#puts "ESTO TE INTERESA: ",coordenadas[0], embarcacion.tamaño
			
			for each in (coordenadas[0]..coordenadas[0]+embarcacion.tamaño-1)
				@matriz[coordenadas[1]][each] = "B"
				embarcacion.coordenadas.push([each,coordenadas[1]])
				
			end
			return true #significa que el barco se pudo colocar correctamente
		elsif orientación == "V" && coordenadas[1]+embarcacion.tamaño-1 < 10
			for each in (coordenadas[1]..coordenadas[1]+embarcacion.tamaño-1)
				@matriz[each][coordenadas[0]] = "B"
				embarcacion.coordenadas.push([coordenadas[0],each])
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

#tipos_barcos = %w{lancha crucero submarino buque portaaviones}
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
		print "Ingresar coordenada x: "
		x = (gets.to_i) -1
		print "Ingresar coordenada y: "
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
			puts "LE DISTEEEEEEE!!!!!!!!!!!!!! MAQUINA"
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
	def pedir_coordenadas()
		#le pide coordenadas al bot

		return Random.rand(10),Random.rand(10)
	end

	def pedir_datos()
		#le pide los datos necesarios al bot para poner un barco
		
		x,y = pedir_coordenadas()
		orientación = %w{H V}[Random.rand(2)]
		
		return x, y,orientación
	end

	def atacar(tabla,enemigo)
		las_coordenadas = pedir_coordenadas()		
		barco_atacado = enemigo.barcos.find {|barquito| barquito.coordenadas.any? {|coordenada_barco| coordenada_barco == las_coordenadas}} #es el barco que esta bajo ataque
		if barco_atacado != nil
			color = "\033[31m" #esto es el color rojo
			barco_atacado.vida -= 1
			barco_atacado.coordenadas.delete las_coordenadas
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
	oceano.poner_barco!(el_jugador.barcos[idx],orientación,[x,y]) 
	
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

#esta sección es para que el bot ponga sus barcos
for idx in (0..4).to_a.reverse!
	x,y,orientación = el_bot.pedir_datos()
	while !(oceano_bot.poner_barco!(el_bot.barcos[idx],orientación,[x,y]))
		x,y,orientación = el_bot.pedir_datos()
	end
	
end

#el_bot.barcos.each {|barcaza| print barcaza.coordenadas}
#termina la sección del bot para la colocación de barcos

puts "MUY BIEN!, ahora tenés que hundir a la flota enemiga"

while true
	el_jugador.atacar(tiro,el_bot)
	tiro.mostrar
	oceano.mostrar
	el_bot.atacar(oceano,el_jugador)
	if !el_bot.vivo?
		puts "¡GANASTE!"
		break
	elsif !el_jugador.vivo?
		puts "PERDISTE"
		break
	end
end