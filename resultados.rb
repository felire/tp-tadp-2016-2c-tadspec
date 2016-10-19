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


class Resultado_test
  attr_accessor :nombre, :asserts

  def initialize metodo
    self.nombre= metodo.to_s
    self.asserts=[]
  end

  def agregar_assert resultado
    self.asserts= self.asserts+[resultado]
  end

  def mostrar_nombre
    puts nombre
  end

  def assert_fallidos
    self.asserts.select{|assert| !assert.paso?}
  end

  def mostrar_resultados
    puts nombre
    self.assert_fallidos.each{|assert|puts assert.descripcion}
    puts ''
  end

  def paso?
    return self.asserts.all?{|assert|assert.paso?}
  end

  def exploto?
    return false
  end
end


class Resultado_test_explotado
  attr_accessor :nombre, :error, :backtrace

  def initialize metodo,excepcion
    self.nombre= metodo.to_s
    self.error= excepcion.message
    self.backtrace=excepcion.backtrace.inspect
  end
  def mostrar_resultados
    puts nombre
    puts 'Excepcion: '+self.error
    #EL BACKTRACE ES LARGO, SI QUERES DESCOMENTALO
    puts 'Backtrace: '+self.backtrace
    puts ''
  end

  def paso?
    return false
  end

  def exploto?
    true
  end
end

class Gestionador_resultados
  include Singleton
  attr_accessor :tests, :asserts_test

  def initialize
    self.tests=[]
    self.asserts_test=[]
  end

  def fin_metodo metodo
    @test_actual=Resultado_test.new metodo
    self.asserts_test.each { |assert| @test_actual.agregar_assert assert }
    self.asserts_test =[]
    self.tests= self.tests + [@test_actual]
    return @test_actual.paso?
  end

  def test_explotado metodo,excepcion
    @test_explotado=Resultado_test_explotado.new metodo,excepcion
    self.asserts_test =[]
    self.tests= self.tests + [@test_explotado]
    return @test_explotado.paso?
  end

  def agregar_assert resultado
    self.asserts_test = self.asserts_test + [resultado]
  end

  def test_pasados
    return self.tests.select {|test| test.paso?}
  end

  def test_fallados
    return self.tests.select{|test| !(test.paso?)&& !(test.exploto?)}
  end

  def test_explotados
    return self.tests.select {|test| test.exploto?}
  end

  def mostrar_resultados
    puts 'Total tests corridos: '+ self.tests.size.to_s
    puts 'Total tests pasados: '+self.test_pasados.size.to_s
    puts 'Total tests fallados: '+self.test_fallados.size.to_s
    puts 'Total tests explotados: '+self.test_explotados.size.to_s,''
    puts 'Tests pasados:'
    self.test_pasados.each{|test| test.mostrar_nombre}
    puts '','Tests fallados:'
    self.test_fallados.each{|test| test.mostrar_resultados}
    puts '','Tests explotados:'
    self.test_explotados.each{|test| test.mostrar_resultados}
    self.tests=[]
    self.asserts_test =[]
  end
end



class Ser
  attr_accessor :valor_esperado

  def initialize val
    self.valor_esperado= val
  end

  def match obj
    if valor_esperado.respond_to? :match
      resultado = valor_esperado.match obj #El matcher imprime la descripcion
    else
      if obj == valor_esperado
        @resultado=Assert_pasado.new
        @resultado.descripcion='El resultado fue el esperado: ' + valor_esperado.to_s+ ' es '+ obj.to_s
        Gestionador_resultados.instance.agregar_assert @resultado
      else
        @resultado=Assert_fallado.new
        @resultado.descripcion= 'Se esperaba '+valor_esperado.to_s+' pero se obtuvo '+obj.to_s
        Gestionador_resultados.instance.agregar_assert @resultado
      end
    end
  end
end

class Mayor_a
  attr_accessor :valor_esperado

  def initialize valor
    self.valor_esperado= valor
  end

  def match obj
    if obj > valor_esperado
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado: '+obj.to_s+' es mayor a '+ valor_esperado.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'Se esperaba un valor mayor a '+valor_esperado.to_s+' pero se obtuvo '+obj.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Menor_a
  attr_accessor :valor_esperado

  def initialize valor
    self.valor_esperado= valor
  end

  def match obj
    if obj < valor_esperado
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado: '+obj.to_s+' es menor a '+ valor_esperado.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'Se esperaba un valor menor a '+valor_esperado.to_s+' pero se obtuvo '+obj.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Uno_de_estos
  attr_accessor :valores_esperados

  def initialize val
    self.valores_esperados= val
  end

  def match obj
    if valores_esperados.include? obj
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado: '+obj.to_s+' es uno de estos valores '+valores_esperados.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'Se esperaba uno de estos valores: '+valores_esperados.to_s+' pero se obtuvo '+obj.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Ser_
  attr_accessor :metodo

  def initialize met
    self.metodo= met
  end

  def match obj
    if obj.send(metodo)
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado: '+obj.class.to_s+' es '+metodo.to_s[0...-1]
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'El objeto '+obj.class.to_s+' no es :'+metodo.to_s[0...-1]
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Tener_
  attr_accessor :atributo, :matcher

  def initialize atributo, matcher
    self.atributo= atributo
    self.matcher= matcher
  end

  def match obj
    var = obj.instance_variable_get(atributo)
    matcher.match var
  end
end

class Entender
  attr_accessor :mensaje

  def initialize mensaje
    self.mensaje= mensaje
  end

  def match obj
    if obj.respond_to? mensaje
      @resultado=Assert_pasado.new
      @resultado.descripcion='El resultado fue el esperado: '+ obj.class.to_s+' entiende el mensaje :'+mensaje.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    else
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'El objeto '+obj.class.to_s+' no entendio el mensaje :'+mensaje.to_s
      Gestionador_resultados.instance.agregar_assert @resultado
    end
  end
end

class Explotar_con
  attr_accessor :excepcion

  def initialize excepcion
    self.excepcion = excepcion
  end

  def match obj
    begin
      obj.call
      @resultado=Assert_fallado.new
      @resultado.descripcion= 'El objeto '+obj.class.to_s+' no lanzo la excepcion '+excepcion.to_s + ', ni siquiera lanzo excepcion!'
      Gestionador_resultados.instance.agregar_assert @resultado
    rescue Exception=>e
      if e.class == excepcion
        @resultado=Assert_pasado.new
        Gestionador_resultados.instance.agregar_assert @resultado
      else
        @resultado=Assert_fallado.new
        @resultado.descripcion= 'El objeto '+obj.class.to_s+' no lanzo la excepcion '+excepcion.to_s
        Gestionador_resultados.instance.agregar_assert @resultado
      end
    end
  end
end

class Haber_recibido
  attr_accessor :metodo, :cant_llamadas, :parametros

  def initialize metodo
    self.metodo = metodo
    self.cant_llamadas = nil
    self.parametros = nil
  end

  def con_argumentos *parametros
    self.parametros = *parametros
    return self
  end

  def veces cantidad
    self.cant_llamadas = cantidad
    return self
  end

  def match objeto
    metodos_llamados = TADsPec.obtener_metodos_espiados objeto
    if(cant_llamadas != nil)
      llamadas_reales = (metodos_llamados.select{|m| (m.metodo == self.metodo) }).size
      if(cant_llamadas == (llamadas_reales))
        resultado = Assert_pasado.new
        Gestionador_resultados.instance.agregar_assert resultado
      else
        resultado = Assert_fallado.new
        resultado.descripcion = 'Se esperaba que el metodo :'+metodo.to_s+' se haya llamado '+cant_llamadas.to_s+' pero se llamo '+llamadas_reales.to_s+' veces'
        Gestionador_resultados.instance.agregar_assert resultado
      end
    elsif(parametros != nil)
      metodosRepetidos = metodos_llamados.select {|m| (m.metodo == metodo)}
      if(metodosRepetidos.any?{|m| (m.parametros == parametros) })
        resultado = Assert_pasado.new
        Gestionador_resultados.instance.agregar_assert resultado
      else
        resultado = Assert_fallado.new
        resultado.descripcion = 'Se esperaba que el metodo :'+metodo.to_s+' se haya llamado con estos argumentos '+parametros.to_s+' pero se llamo con estos: '+"\n"
        metodosRepetidos.each {|metodo| resultado.descripcion = resultado.descripcion+ metodo.parametros.to_s + "\n"}
        Gestionador_resultados.instance.agregar_assert resultado
      end
    else
      if(metodos_llamados.any?{|m| m.metodo == metodo })
        resultado = Assert_pasado.new
        Gestionador_resultados.instance.agregar_assert resultado
      else
        resultado = Assert_fallado.new
        resultado.descripcion = 'Se esperaba que el metodo :' + metodo.to_s+' fuera llamado por el objeto ' + objeto.class.to_s + ' pero no lo fue.'
        Gestionador_resultados.instance.agregar_assert resultado
      end
    end
  end
end
