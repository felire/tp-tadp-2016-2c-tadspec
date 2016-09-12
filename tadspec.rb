require './test_initializer.rb'
require './resultados.rb'


class Ser

  def initialize val
    @valor= val
  end

  def match obj
    if @valor.respond_to? :match
      puts @valor.match obj
      @valor.match obj
    else
      puts obj == @valor
      obj == @valor
    end
  end
end

class Uno_de_estos

  def initialize val
    @array= val
  end

  def match obj
    @array.include? obj
  end
end

class Ser_

  def initialize met
    @metodo= met
  end

  def match obj
    puts obj.send(@metodo)
    obj.send(@metodo)
  end
end

class Tener_

  def initialize atributo, matcher
    @atributo= atributo
    @matcher= matcher
  end

  def match obj
    var = obj.instance_variable_get(@atributo)
    puts @matcher.match var
    @matcher.match var
  end
end

class Mayor_a

  def initialize valor
    @valor= valor
  end

  def match obj
    obj > @valor
  end
end

class Menor_a

  def initialize valor
    @valor= valor
  end

  def match obj
    obj < @valor
  end
end


class Entender

  def initialize mensaje
    @mensaje= mensaje
  end

  def match obj
    puts obj.respond_to? @mensaje
    obj.respond_to? @mensaje
  end
end

class Explotar_con

  def initialize excepcion
    @excepcion = excepcion
  end

  def match obj
    begin
      obj.call
    rescue Exception=>e
      return e.class == excepcion
    end
    return false
  end
end


class Mock

  def set_clase c
    @clase = c
  end
  def set_metodo m
    @metodo = m
  end
  def set_cuerpo c
    @cuerpo = c
  end
  def restaurar
    @clase.send(:define_method, @metodo, @cuerpo)
  end
end

class TADsPec

  @@resultados_asserts = []
  @@mocks = []


  def self.is_suite? clase
    clase.instance_methods.any?{|me| is_test? me}
  end

  def self.is_test? metodo
    metodo.to_s.start_with?'testear_que_'
  end

  def self.obtener_lista_suites
    clases = []
    ObjectSpace.each_object(Class).each do |valor|
      clases = clases + [valor]
    end
    listaSuitsYSingletons = clases.select {|clase| TADsPec.is_suite? clase}
    listaSuits = listaSuitsYSingletons.select {|clase| !(clase.to_s.start_with? '#')} #sacamos a las singletons
    return listaSuits
  end

  def self.imprimir_lista_resultados
    @@resultados_asserts.each { |a| a.imprimir_resultado_test}
  end

  def self.mostrar_resultado
    cantidadCorridos = @@resultados_asserts.length
    pasados = @@resultados_asserts.select {|test| test.paso_test?}
    cantidadPasados= pasados.length
    fallados = @@resultados_asserts.select{|test| test.fallo_test?}
    cantidadFallados = fallados.length
    explotados = @@resultados_asserts.select{|test| test.exploto_test?}
    cantidadExplotados = explotados.length
    puts 'Se corrieron '+ cantidadCorridos.to_s+ ' tests:'
    puts 'Pasados: '+cantidadPasados.to_s
    puts 'Fallados: '+cantidadFallados.to_s
    puts 'Explotados: '+cantidadExplotados.to_s
    puts ' '
    puts 'Test Pasados con exito: '
    pasados.each{|test| puts 'Nombre: '+ test.get_nombre_test.to_s}
    puts ' '
    puts 'Test Fallidos: '
    fallados.each{|test|
      puts 'Nombre: ' + test.get_nombre_test.to_s
      puts ''
      puts 'Descripcion falla: '
      puts ' '
      test.mensaje_fallo
    }
    return

  end

  def self.agregar_asercion_actual booleano
    @@resultadoMetodo.add booleano
  end

  def self.agregar_mock clase, metodo, cuerpo
    mockNvo = Mock.new
    mockNvo.set_clase clase
    mockNvo.set_metodo metodo
    mockNvo.set_cuerpo cuerpo
    @@mocks = @@mocks+[mockNvo]
  end

  def self.borrar_mocks
    @@mocks.each {|mock| mock.restaurar}
    @@mocks = []
  end

  def self.transformar_metodos_testear args
    metodos = []
    args.each {|metodo| metodos = metodos + ['testear_que_' + metodo.to_s]}
    return metodos
  end

  def self.testear_metodo instancia, metodo
    @@resultadoMetodo = ResultadoTest.new
    @@resultadoMetodo.set_nombre_test metodo
    instancia.send(metodo)
    @@resultados_asserts = @@resultados_asserts+[@@resultadoMetodo]
    TADsPec.borrar_mocks
    @@resultadoMetodo
  end

  def self.ejecutar_test_suite claseATestear
    instancia = claseATestear.new
    TestInitializer.agregar_metodos_a_suite instancia
    metodos = instancia.methods
    metodos = metodos.select {|metodo| TADsPec.is_test? metodo}
    metodos.each {|metodo|
      TADsPec.testear_metodo instancia, metodo }
  end

  def self.testear *args
    TestInitializer.inicializar_tests
    if(args[0] == nil)
      TADsPec.obtener_lista_suites.each {|suit| TADsPec.ejecutar_test_suite suit}
    elsif((TADsPec.is_suite? args[0]) && args[1] == nil)
      self.ejecutar_test_suite args[0]
    elsif((TADsPec.is_suite? args[0]) && args[1] != nil)
      instancia = args[0].new
      TestInitializer.agregar_metodos_a_suite instancia
      metodos = TADsPec.transformar_metodos_testear args[1..-1]
      metodos.each{|metodo| TADsPec.testear_metodo instancia, metodo}
    end
    TestInitializer.finalizar_tests
    #TADsPec.mostrar_resultado
    @@resultados_asserts = []
    return
  end
end

class Persona
  def viejo?
    @edad > 29
  end
  def set a
    @edad = a
  end
  def get
    @edad
  end
end

class Suit

  def testear_que_soy_yo
    7.deberia ser 7
    #7.deberia ser menor_a 6
    7.deberia ser uno_de_estos [1,2,3,7]
    #7.deberia ser uno_de_estos [1,2,3]
    a = Persona.new
    a.set 30
    a.deberia ser_viejo
    a.deberia tener_edad 30
    a.deberia tener_edad menor_a 90
    a.deberia tener_edad uno_de_estos [7, 22, "hola", 30]
    Object.deberia entender :new
    a.deberia entender :set
    #a = bloq { 7 / 0 }

    #a.deberia explotar_con ZeroDivisionError
  end
end
