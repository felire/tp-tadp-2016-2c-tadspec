class TADsPec

    @@resultados_asserts = []
    @@mayor_a =  Proc.new do |valor|  self > valor end
    @@menor_a = Proc.new do |valor| self < valor end
    @@uno_de_estos = Proc.new do |valor| valor.include? self end

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
    |args| if(args.is_a? Array)
             TADsPec.agregar_asercion_actual self.instance_exec(args[1], &args[0])
           else
             TADsPec.agregar_asercion_actual self == args
           end
    end
  end

  def self.agregar_metodos_suites clase
    clase.send(:define_method,:mayor_a) do |valor|
      return [@@mayor_a , valor]
    end
    clase.send(:define_method,:menor_a) do |valor|
      return [@@menor_a, valor]
    end
    clase.send(:define_method,:uno_de_estos) do |valor|
      return [@@uno_de_estos, valor]
    end
    clase.send(:define_method,:ser) do |valor|
      return valor
    end
    clase.send(:define_method,:method_missing) do |symbol,*args|
      if(symbol.to_s.start_with? 'ser_')
        metodo = symbol.to_s[4..-1] +'?'
        return [Proc.new do self.send(metodo) end]
      end
      if(symbol.to_s.start_with? 'tener_')
        atributo = '@' + symbol.to_s[6..-1]
        if(args[0].is_a? Array)
          return [Proc.new do self.instance_variable_get(atributo).instance_exec(args[0][1], &args[0][0]) end]
        else
          return [Proc.new do self.instance_variable_get(atributo) == args[0] end]
        end
      else
        super(symbol, *args)
      end
    end
  end

  def self.testear_metodo clase , metodo
    instancia = clase.new
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
    TADsPec.agregar_metodos_suites claseATestear
    metodos = instancia.methods
    metodos = metodos.select {|metodo| TADsPec.is_test? metodo}
    metodos.each {|metodo|
    @@resultadoMetodo = ResultadoTest.new
    @@resultados_asserts = @@resultados_asserts+[@@resultadoMetodo]
    instancia.send(metodo)}
  end

  def self.transformar_metodos_testear args
    metodos = []
    args.each {|metodo| metodos = metodos + ['testear_que_' + metodo.to_s]}
    return metodos
  end

  def self.quitar_metodos clase
    clase.send(:remove_method, :mayor_a)
    clase.send(:remove_method, :menor_a)
    clase.send(:remove_method, :uno_de_estos)
    clase.send(:remove_method, :ser)
    clase.send(:remove_method, :mayor_a)
  end

  def self.testear *args
      self.agregar_deberia
      if(args[0] == nil)
        TADsPec.obtener_lista_suits.each {|suit| TADsPec.ejecutar_test_suit suit}
      elsif((TADsPec.is_suite? args[0]) && args[1] == nil)
        self.ejecutar_test_suit args[0]
      elsif((TADsPec.is_suite? args[0]) && args[1] != nil)
        self.agregar_metodos_suites args[0]
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
    @resultados.each{ |a| puts a}
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

  def self.testeame
    TADsPec.testear Suite , :testear_que_es_7
  end
end

class Suite2
  def testear_que_es_7
    7.deberia ser 7
  end

  def testear_que_hola
    7.deberia ser 8
    7.deberia ser mayor_a 2
    7.deberia ser mayor_a 8
  end

end

