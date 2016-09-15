class ResultadoTest #Resultado de un metodo test

  attr_accessor :nombreTest, :nombreSuit, :desc_error, :resultados
  def initialize
    resultados= Array.new #Contiene la lista de resultados de los assserts dentro del  test
  end

  def resultado_final?   #Devuelve el resultado final del test
    resultados.all? {|resultado| resultado}
  end

  def add resultadoAssert
    resultados= resultados+[resultadoAssert]
  end

  def paso_test?
    resultados.all? {|resultadoAssert| resultadoAssert.paso?}
  end

  def fallo_test?
    resultados.any? {|resultadoAssert| resultadoAssert.fallo?} && @resultados.all? {|resultadoAssert| !resultadoAssert.exploto?}
  end

  def exploto_test?
    resultados.any?{|resultadoAssert| resultadoAssert.exploto?}
  end

  def assert_fallidos
    resultados.select{|assert| assert.fallo?}
  end
  def mensaje_fallo
    self.assert_fallidos.each{|assert| assert.mostrar}
  end

  def imprimir_resultado_test
    resultados.each{ |a| a.mostrar}
  end
end

class ResultadoAssert
  attr_accessor :descripcion, :resultado, :excepcion

  # resultado: 1 paso, 2 fallo, 3 exploto
  # excepcion: es nil a menos que el resultado sea 3

  def mostrar
    puts @descripcion
    puts ' '
  end

  def paso?
    resultado == 1
  end

  def fallo?
    resultado == 2
  end

  def exploto?
    resultado == 3
  end
end


class Ser
  attr_accessor :valorEsperado

  def initialize val
    @valorEsperado= val
  end

  def match obj
    if valorEsperado.respond_to? :match
      resultado = valorEsperado.match obj #El matcher imprime la descripcion
    else
      resultado = obj == valorEsperado
      if resultado
        puts 'El resultado fue el esperado'
      else
        puts 'Se esperaba '+valorEsperado.to_s+' pero se obtuvo '+obj.to_s
      end
    end
    resultado
  end
end

class Mayor_a
  attr_accessor :valorEsperado

  def initialize valor
    @valorEsperado= valor
  end

  def match obj
    resultado = (obj > valorEsperado)
    if resultado
      puts 'El resultado fue el esperado'
    else
     puts 'Se esperaba un valor mayor a '+valorEsperado.to_s+' pero se obtuvo '+obj.to_s
    end
    resultado
  end
end

class Menor_a
  attr_accessor :valorEsperado

  def initialize valor
   @valorEsperado= valor
  end

  def match obj
    resultado = (obj < valorEsperado)
    if resultado
      puts 'El resultado fue el esperado'
    else
      puts 'Se esperaba un valor menor a '+valorEsperado.to_s+' pero se obtuvo '+obj.to_s
    end
    resultado
  end
end

class Uno_de_estos
  attr_accessor :valoresEsperados

  def initialize val
    @valoresEsperados= val
  end

  def match obj
    resultado = valoresEsperados.include? obj
    if resultado
      puts 'El resultado fue el esperado'
    else
      puts 'Se esperaba un valor de '+valoresEsperados.to_s+' pero se obtuvo '+obj.to_s
    end
    resultado
  end
end

class Ser_
    attr_accessor :metodo

  def initialize met
    @metodo= met
  end

  def match obj
    resultado = obj.send(metodo)
    if resultado
      puts 'El resultado fue el esperado'
    else
      puts 'El objeto '+obj.class.to_s+' no es '+metodo.to_s[0...-1]
    end
    resultado
  end
end

class Tener_
  attr_accessor :atributo, :matcher

  def initialize atributo, matcher
    @atributo= atributo
    @matcher= matcher
  end

  def match obj
    var = obj.instance_variable_get(atributo)
    matcher.match var
  end
end

class Entender
  attr_accessor :mensaje

  def initialize mensaje
    @mensaje= mensaje
  end

  def match obj
   resultado = obj.respond_to? mensaje
    if resultado
      puts 'El resultado fue el esperado'
    else
      puts 'El objeto '+obj.class.to_s+' no entendio el mensaje '+mensaje.to_s
    end
    resultado
  end
end

class Explotar_con #Santi: nose testear esto asi que nose si esta bien
  attr_accessor :excepcion

  def initialize excepcion
    @excepcion = excepcion
  end

  def match obj
    begin
      obj.call
    rescue Exception=>e
      resultado = (e.class == excepcion)
      if resultado
        puts 'El resultado fue el esperado'
      else
        puts 'El objeto '+obj.class.to_s+' no lanzo la excepcion '+excepcion.to_s
      end
      return resultado
    end
    puts 'El objeto '+obj.class.to_s+' no lanzo la excepcion '+excepcion.to_s
    return false
  end
end

class Haber_recibido

  def initialize metodo
    @metodo = metodo
    @veces = nil
    @parametros = nil
  end

  def con_parametros parametros
    @parametros = parametros
  end

  def veces cantidad
    @cantidad = cantidad
  end

  def match objeto
    @metodos_llamados = TADsPec.obtener_metodos objeto
    if(@veces != nil)
      @cantidad == (@metodos_llamados.select{|m| (m.metodo == @metodo) }).size
    elsif(@parametros != nil)
      @metodos_llamados.any?{|m| (m.metodo == @metodo) && (m.parametros == @parametros) }
    else
      @metodos_llamados.any?{|m| m.metodo == @metodo }
    end
  end
end
