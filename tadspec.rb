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
  end
end

class TADsPec

    @@resultados_asserts = []
    @@uno_de_estos = Proc.new do |valor|
      resultado= ResultadoAssert.new
      if(valor.include? self)
        resultado.set_descripcion 'El resultado fue el esperado: '+ self.to_s + ' esta en la lista'
        resultado.set_resultado 1
      else
        resultado.set_descripcion 'FALLO: '+ self.to_s + ' no se encuentra en la lista'
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
        resultado.set_descripcion 'El resultado no fue el esperado'
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
      resultado.set_descripcion 'El resultado no fue el esperado'
      resultado.set_resultado 2
      end
      resultado
    end

    @@tener_ = Proc.new do |args|
    resultado = ResultadoAssert.new
      if(args[1].is_a? Array)
        if(self.instance_variable_get(args[0]).instance_exec(args[1][1], &args[1][0]))
          resultado.set_descripcion 'El resultado fue el esperado'
          resultado.set_resultado 1
        else
          resultado.set_descripcion 'El resultado no fue el esperado'
          resultado.set_resultado 2
        end
      else
        if(self.instance_variable_get(args[0]) == args[1])
          resultado.set_descripcion 'El resultado fue el esperado'
          resultado.set_resultado 1
        else
          resultado.set_descripcion 'El resultado no fue el esperado'
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

  def self.agregar_asercion_actual booleano
    @@resultadoMetodo.add booleano
  end

  def self.agregar_deberia
    Object.send(:define_method,:deberia) do
    |args|
             TADsPec.agregar_asercion_actual self.instance_exec(args[1], &args[0])
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
      if (!valor.is_a? Array)
        return [@@ser, valor]
      else
        return valor
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
        #if(args[0].is_a? Array)
        #  return [Proc.new do self.instance_variable_get(atributo).instance_exec(args[0][1], &args[0][0]) end]
        #else
        #  return [Proc.new do self.instance_variable_get(atributo) == args[0] end]
        #end
      else
        super(symbol, *args)
      end
    end
  end

    def self.testear_metodo clase , metodo
    instancia = clase.new
    self.agregar_metodos_suites instancia
    @@resultadoMetodo = ResultadoTest.new
    instancia.send(metodo)
    @@resultados_asserts = @@resultados_asserts+[@@resultadoMetodo]
  end

  def self.obtener_lista_suits
    clases = []
    ObjectSpace.each_object(Class).each do
    |valor| clases = clases + [valor]
    end
    listaSuits = clases.select {|clase| TADsPec.is_suite? clase}
    return listaSuits
  end

  def self.ejecutar_test_suit claseATestear
    instancia = claseATestear.new
    TADsPec.agregar_metodos_suites instancia
    metodos = instancia.methods
    metodos = metodos.select {|metodo| TADsPec.is_test? metodo}
    metodos.each {|metodo|
    @@resultadoMetodo = ResultadoTest.new
    instancia.send(metodo)
    @@resultados_asserts = @@resultados_asserts+[@@resultadoMetodo] }
  end

  def self.transformar_metodos_testear args
    metodos = []
    args.each {|metodo| metodos = metodos + ['testear_que_' + metodo.to_s]}
    return metodos
  end

  def self.testear *args
      self.agregar_deberia
      if(args[0] == nil)
        TADsPec.obtener_lista_suits.each {|suit| TADsPec.ejecutar_test_suit suit}
      elsif((TADsPec.is_suite? args[0]) && args[1] == nil)
        self.ejecutar_test_suit args[0]
      elsif((TADsPec.is_suite? args[0]) && args[1] != nil)
        metodos = TADsPec.transformar_metodos_testear args[1..-1]
        metodos.each{|metodo| TADsPec.testear_metodo args[0], metodo}
      end
      Object.send(:remove_method,:deberia)
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

  def resultado_final?   #Devuelve el resultado final del test
    @resultados.all? {|resultado| resultado}
  end

  def get_desc_error
    @desc_error
  end

  def add resultadoAssert
    @resultados = @resultados+[resultadoAssert]
  end

  def imprimir_mierdita
    @resultados.each{ |a| a.mostrar}
  end
end


class Suite
  def testear_que_es_7
    7.deberia ser 7
  end

  def testear_que_hola
    7.deberia ser 8
    7.deberia ser mayor_a 2
    7.deberia ser mayor_a 8
  end
end

class Suite2
  def testear_que_es_8
    7.deberia ser 8
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

class SuitPi

  def initialize
  @nico = Persona.new
  @nico.set 30
  @leandro = Persona.new
  @leandro.set 22
  end

  def testear_que_holis
  @nico.deberia ser_viejo    # pasa: Nico tiene edad 30. #@nico.viejo?.deberia ser true # La linea de arriba es equivalente a esta
  @leandro.deberia ser_viejo # falla: Leandro tiene 22.

  @leandro.deberia tener_edad 22 # pasa

  #leandro.deberia tener_nombre "leandro" # falla: no hay atributo nombre

  @leandro.deberia tener_nombre nil # pasa

  @leandro.deberia tener_edad mayor_a 20 # pasa

  @leandro.deberia tener_edad menor_a 25 # pasa

  @leandro.deberia tener_edad uno_de_estos [7, 22, "hola"] # pasa
  #@leandro.deberia ser_joven # explota: Leandro no entiende el mensaje joven?
  end
end

