require 'singleton'


class Resultado_assert
  attr_accessor :descripcion

end

class Assert_pasado<Resultado_assert
  def paso?
    return true
  end

end

class Assert_fallado<Resultado_assert
  def paso?
    return false
  end
end

class Assert_explotado<Resultado_assert
  def paso?
    return false
  end
end

class Resultado_test
  attr_accessor :nombre, :asserts

  def initialize metodo
    self.nombre= metodo.to_s
    self.asserts=[]
  end

  def agregar_assert resultado
    self.asserts= self.asserts+[resultado]
  end

  def mostrar_resultados
    self.asserts.each{|assert|puts assert.descripcion}
  end
end


class Gestionador_resultados
  include Singleton
  attr_accessor :tests, :testActual

  def initialize
    self.tests=[]
  end

  def nuevo_test metodo
    self.testActual= Resultado_test.new metodo
  end

  def fin_metodo
    self.tests= self.tests + [self.testActual]
  end

  def agregar_assert resultado
    self.testActual.agregar_assert resultado
  end

  def mostrar_resultados
    self.tests.each{|test|test.mostrar_resultados}
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
      if obj == valorEsperado
        @resultado=Assert_pasado.new
        @resultado.descripcion='El resultado fue el esperado'
        Gestionador_resultados.instance.agregar_assert @resultado
      else
        @resultado=Assert_fallado.new
        @resultado.descripcion= 'Se esperaba '+valorEsperado.to_s+' pero se obtuvo '+obj.to_s
        Gestionador_resultados.instance.agregar_assert @resultado
      end
    end
  end
end

class Mayor_a
  attr_accessor :valorEsperado

  def initialize valor
    @valorEsperado= valor
  end

  def match obj
    if obj > valorEsperado
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado'
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'Se esperaba un valor mayor a '+valorEsperado.to_s+' pero se obtuvo '+obj.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Menor_a
  attr_accessor :valorEsperado

  def initialize valor
   @valorEsperado= valor
  end

  def match obj
    if obj < valorEsperado
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado'
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'Se esperaba un valor menor a '+valorEsperado.to_s+' pero se obtuvo '+obj.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Uno_de_estos
  attr_accessor :valoresEsperados

  def initialize val
    @valoresEsperados= val
  end

  def match obj
    if valoresEsperados.include? obj
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado'
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'Se esperaba un valor de '+valoresEsperados.to_s+' pero se obtuvo '+obj.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Ser_
    attr_accessor :metodo

  def initialize met
    @metodo= met
  end

  def match obj
    if obj.send(metodo)
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado'
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'El objeto '+obj.class.to_s+' no es '+metodo.to_s[0...-1]
      Gestionador_resultados.instance.agregar_assert @resultado
    end
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
   if obj.respond_to? mensaje
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado'
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'El objeto '+obj.class.to_s+' no entendio el mensaje '+mensaje.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
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
      if e.class == excepcion
        @resultado=Assert_pasado.new
        @resultado.descripcion='El resultado fue el esperado'
        Gestionador_resultados.instance.agregar_assert @resultado
      else
        @resultado=Assert_fallado.new
        @resultado.descripcion= 'El objeto '+obj.class.to_s+' no lanzo la excepcion '+excepcion.to_s
        Gestionador_resultados.instance.agregar_assert @resultado
      end
    end
    @resultado=Assert_fallado.new
    @resultado.descripcion= 'El objeto '+obj.class.to_s+' no lanzo la excepcion '+excepcion.to_s
    Gestionador_resultados.instance.agregar_assert @resultado
  end
end

class Haber_recibido

  def initialize metodo
    @metodo = metodo
    @cant_llamadas = nil
    @parametros = nil
  end

  def con_argumentos *parametros
    @parametros = *parametros
    return self
  end

  def veces cantidad
    @cant_llamadas = cantidad
    return self
  end

  def match objeto
    @metodos_llamados = TADsPec.obtener_metodos objeto
    if(@cant_llamadas != nil)
      puts @cant_llamadas == (@metodos_llamados.select{|m| (m.metodo == @metodo) }).size
    elsif(@parametros != nil)
      puts @metodos_llamados.any?{|m| (m.metodo == @metodo) && (m.parametros == @parametros) }
    else
     puts @metodos_llamados.any?{|m| m.metodo == @metodo }
    end
  end
end
