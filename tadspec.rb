require './test_initializer.rb'
class Mock
  @clase
  @metodo
  @cuerpo

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

class ResultadoAssert

  @descripcion
  @resultado # 1 paso, 2 fallo, 3 exploto
  @excepcion # es nil a menos que el resultado sea 3

  def set_descripcion desc
    @descripcion = desc
  end
  def set_resultado resultado
    @resultado = resultado
  end
  def get_resultado
    @resultado
  end
  def get_descripcion
    @descripcion
  end
  def mostrar
    puts @descripcion
    puts ' '
  end
  def paso?
    @resultado == 1
  end
  def fallo?
    @resultado == 2
  end
  def exploto?
    @resultado == 3
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

  def self.obtener_lista_suites
    clases = []
    ObjectSpace.each_object(Class).each do |valor|
      clases = clases + [valor]
    end
    listaSuitsYSingletons = clases.select {|clase| TADsPec.is_suite? clase}
    listaSuits = listaSuitsYSingletons.select {|clase| !(clase.to_s.start_with? '#')} #sacamos a las singletons
    return listaSuits
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
    TADsPec.agregar_metodos_suites instancia
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
    TADsPec.mostrar_resultado
    @@resultados_asserts = []
    return
  end
end


class ResultadoTest #Resultado de un metodo test
  def initialize
    @resultados = Array.new #Contiene la lista de resultados de los assserts dentro del  test
  end

  def get_nombre_test
    @nombreTest
  end

  def set_nombre_test nombre
    @nombreTest = nombre
  end
  def get_nombre_suit
    @nombreSuit
  end
  def set_nombre_suit nombre
    @nombreSuit = nombre
  end
  def resultado_final?   #Devuelve el resultado final del test
    @resultados.all? {|resultado| resultado}
  end

  def get_desc_error
    @desc_error
  end

  def add resultadoAssert
    @resultados = @resultados+[resultadoAssert]
  end

  def paso_test?
    @resultados.all? {|resultadoAssert| resultadoAssert.paso?}
  end

  def fallo_test?
    @resultados.any? {|resultadoAssert| resultadoAssert.fallo?} && @resultados.all? {|resultadoAssert| !resultadoAssert.exploto?}
  end

  def exploto_test?
    @resultados.any?{|resultadoAssert| resultadoAssert.exploto?}
  end

  def assert_fallidos
    @resultados.select{|assert| assert.fallo?}
  end
  def mensaje_fallo
    self.assert_fallidos.each{|assert| assert.mostrar}
  end

  def imprimir_resultado_test
    @resultados.each{ |a| a.mostrar}
  end
end
