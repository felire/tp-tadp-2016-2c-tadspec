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

  @@uno_de_estos = Proc.new do |valor|
    resultado= ResultadoAssert.new
    if(valor.include? self)
      resultado.set_descripcion 'El resultado fue el esperado: '+ self.to_s + ' esta en la lista'
      resultado.set_resultado 1
    else
      resultado.set_descripcion 'FALLO: '+ self.to_s + ' no se encuentra en la lista: '+ valor.to_s
      resultado.set_resultado 2
    end
    resultado
  end

  @@ser = Proc.new do |valor|
    resultado=ResultadoAssert.new
    if(self == valor)
      resultado.set_descripcion 'El resultado fue el esperado'
      resultado.set_resultado 1
    else
      resultado.set_descripcion 'FALLO: '+self.to_s + ' no es '+ valor.to_s
      resultado.set_resultado 2
    end
    resultado
  end

  @@ser_ = Proc.new do |metodo|
    resultado = ResultadoAssert.new
    if(self.send(metodo))
      resultado.set_descripcion 'El resultado fue el esperado'
      resultado.set_resultado 1
    else
      resultado.set_descripcion 'FALLO: El metodo: '+metodo.to_s+' devuelve false'
      resultado.set_resultado 2
    end
    resultado
  end

  @@tener_ = Proc.new do |args|
    resultado = ResultadoAssert.new
    if((args[1].is_a? Array) && (args[1][0].is_a? Proc))
      resultadoPrueba = self.instance_variable_get(args[0]).instance_exec(args[1][1], &args[1][0])
      if(resultadoPrueba.paso?)
        resultado.set_descripcion 'El resultado fue el esperado'
        resultado.set_resultado 1
      else
        descripcion = resultadoPrueba.get_descripcion
        descripcion = descripcion.to_s[6..-1]
        descripcion = 'FALLO: '+' la variable '+ args[0] + ' de valor '+ self.instance_variable_get(args[0]).to_s + ' tuvo este problema: ' + descripcion
        resultado.set_descripcion descripcion
        resultado.set_resultado 2
      end
    else
      if(self.instance_variable_get(args[0]) == args[1])
        resultado.set_descripcion 'El resultado fue el esperado'
        resultado.set_resultado 1
      else
        resultado.set_descripcion 'FALLO: La variable: '+args[0].to_s+' vale: ' + self.instance_variable_get(args[0]).to_s + ', no: '+args[1].to_s
        resultado.set_resultado 2
      end
    end
    resultado
  end

  @@mayor_a =  Proc.new do |valor|
    resultado = ResultadoAssert.new
    if(self > valor)
      resultado.set_descripcion 'El resultado fue el esperado: ' + self.to_s + '>' + valor.to_s
      resultado.set_resultado 1
    elsif(self < valor)
      resultado.set_descripcion 'FALLO: ' + self.to_s + '<' + valor.to_s + ' y se esperaba que: ' + self.to_s +  '>' +  valor.to_s
      resultado.set_resultado 2
    elsif(self == valor)
      resultado.set_descripcion 'FALLO: ' + self.to_s + '==' + valor.to_s + ' y se esperaba que: ' + self.to_s +  '>' +  valor.to_s
      resultado.set_resultado 2
    end
    resultado
  end

  @@menor_a = Proc.new do |valor|
    resultado = ResultadoAssert.new
    if(self < valor)
      resultado.set_descripcion 'El resultado fue el esperado: ' + self.to_s + ' < ' + valor.to_s
      resultado.set_resultado 1
    elsif(self > valor)
      resultado.set_descripcion 'FALLO: ' + self.to_s + ' > ' + valor.to_s + ' y se esperaba que: ' + self.to_s +  ' < ' +  valor.to_s
      resultado.set_resultado 2
    elsif(self == valor)
      resultado.set_descripcion 'FALLO: ' + self.to_s + ' == ' + valor.to_s + ' y se esperaba que: ' + self.to_s +  ' < ' +  valor.to_s
      resultado.set_resultado 2
    end
    resultado
  end

  @@entender = Proc.new do |mensaje|
    resultado = ResultadoAssert.new
    if(self.respond_to? mensaje)
      resultado.set_descripcion 'El resultado fue el esperado: ' + self.to_s + ' entiende el metodo :' + mensaje.to_s
      resultado.set_resultado 1
    else
      resultado.set_descripcion 'FALLO: ' + self.to_s + ' no entiende el metodo :' + mensaje.to_s
      resultado.set_resultado 2
    end
    resultado
  end

  def self.is_suite? clase
    clase.instance_methods.any?{|me| is_test? me}
  end

  def self.is_test? metodo
    metodo.to_s.start_with?'testear_que_'
  end

  def self.imprimir_mierda
    @@resultados_asserts.each { |a| a.imprimir_mierdita}
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

  def self.agregar_deberia
    BasicObject.send(:define_method,:deberia) do |args|
      TADsPec.agregar_asercion_actual self.instance_exec(args[1], &args[0])
    end
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

  def self.agregar_mockear
    BasicObject.send(:define_method, :mockear) do |nombreMetodo, &bloque|
      cuerpo = self.instance_method(nombreMetodo)
      TADsPec.agregar_mock self, nombreMetodo, cuerpo
      self.send(:define_method, nombreMetodo) do
        self.instance_exec(&bloque)
      end
    end
  end

  def self.agregar_metodos_suites instancia

    instancia.singleton_class.send(:define_method,:mayor_a) do |valor|
      return [@@mayor_a , valor]
    end

    instancia.singleton_class.send(:define_method,:menor_a) do |valor|
      return [@@menor_a, valor]
    end

    instancia.singleton_class.send(:define_method,:uno_de_estos) do |valor|
      return [@@uno_de_estos, valor]
    end

    instancia.singleton_class.send(:define_method,:ser) do |valor|
      if((valor.is_a? Array) && (valor[0].is_a? Proc))
        return valor
      else
        return [@@ser, valor]
      end
    end

    instancia.singleton_class.send(:define_method, :entender) do |mensaje|
      return [@@entender, mensaje]
    end

    instancia.singleton_class.send(:define_method,:method_missing) do |symbol,*args|
      if(symbol.to_s.start_with? 'ser_')
        metodo = symbol.to_s[4..-1] +'?'
        return [@@ser_, metodo]
      end
      if(symbol.to_s.start_with? 'tener_')
        atributo = '@' + symbol.to_s[6..-1]
        return [@@tener_, [atributo, args[0]]]
      else
        super(symbol, *args)
      end
    end
  end

  def self.transformar_metodos_testear args
    metodos = []
    args.each {|metodo| metodos = metodos + ['testear_que_' + metodo.to_s]}
    return metodos
  end

  def self.obtener_lista_suits
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
  end

  def self.ejecutar_test_suit claseATestear
    instancia = claseATestear.new
    TADsPec.agregar_metodos_suites instancia
    metodos = instancia.methods
    metodos = metodos.select {|metodo| TADsPec.is_test? metodo}
    metodos.each {|metodo|
      TADsPec.testear_metodo instancia, metodo }
  end

  def self.testear *args
    self.agregar_deberia
    self.agregar_mockear
    if(args[0] == nil)
      TADsPec.obtener_lista_suits.each {|suit| TADsPec.ejecutar_test_suit suit}
    elsif((TADsPec.is_suite? args[0]) && args[1] == nil)
      self.ejecutar_test_suit args[0]
    elsif((TADsPec.is_suite? args[0]) && args[1] != nil)
      instancia = args[0].new
      TADsPec.agregar_metodos_suites instancia
      metodos = TADsPec.transformar_metodos_testear args[1..-1]
      metodos.each{|metodo| TADsPec.testear_metodo instancia, metodo}
    end
    BasicObject.send(:remove_method,:deberia)
    BasicObject.send(:remove_method,:mockear)
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

  def imprimir_mierdita
    @resultados.each{ |a| a.mostrar}
  end
end

#Tests

class Suite
  def testear_que_es_7
    7.deberia ser 7
  end

  def testear_que_hola
    #7.deberia ser 8
    7.deberia ser mayor_a 2
    #7.deberia ser mayor_a 8
  end
end

class Suite2
  def testear_que_es_8
    7.deberia ser 7
    [1,2].deberia ser [1,2]
    [1,true, false, 1].deberia ser [1,true, false, 1]
  end

  def testear_que_hola
    7.deberia ser mayor_a 2
    7.deberia ser mayor_a 8
    Object.deberia entender :new
  end
end

class Ser_o_no_ser
  def testear_que_true
    true.deberia ser false
    true.deberia ser true
    22.deberia ser uno_de_estos [7, 22, "hola"]
    21.deberia ser uno_de_estos [7, 22, "hola"]
  end
end

class Persona
  @edad
  def initialize
    @lista = [1,2,3]
  end
  def set edad
    @edad = edad
  end
  def edad
    @edad
  end
  def viejo?
    @edad > 29
  end
end

class Numero
  def pepe
    'soy el metodo sin mockear '
  end
end

class Mockeame
  def testear_que_puedo_testear
    Numero.mockear(:pepe) do
      'soy el metodo mockeado'
    end
    num = Numero.new
    puts num.pepe
    7.deberia ser 7
  end
end

class SuitPi

  def initialize
    @nico = Persona.new
    @nico.set 30
    @leandro = Persona.new
    @leandro.set 22

  end

  def testear_que_holis
    @nico.deberia ser_viejo    # pasa: Nico tiene edad 30. #@nico.viejo?.deberia ser true # La linea de arriba es equivalente a esta
    #@leandro.deberia ser_viejo # falla: Leandro tiene 22.
    @leandro.deberia tener_edad 22 # pasa
    #@leandro.deberia tener_edad 23
    #@leandro.deberia tener_nombre "leandro"                                          #Santi: esto dice la variable no es leandro, deberia decir no existe la var edad
    @leandro.deberia tener_nombre nil # pasa
    @leandro.deberia tener_edad mayor_a 20 # pasa
    @leandro.deberia tener_edad menor_a 25 # pasa
    #@leandro.deberia tener_edad mayor_a 23
    @leandro.deberia tener_edad uno_de_estos [7, 22, "hola"] # pasa
    #@leandro.deberia ser_joven # explota: Leandro no entiende el mensaje joven?
  end
  def testear_que_tener
    @leandro.deberia tener_edad mayor_a 23
    [1,2].deberia ser [1,2,3]
    [1,2].deberia ser uno_de_estos [[1],1,[1,2]]
    @leandro.deberia tener_lista [1,2,3,4]
    @leandro.deberia tener_lista uno_de_estos [[1,2,3]]
  end
  def testear_que_funca8
    7.deberia ser mayor_a 7
  end
end
