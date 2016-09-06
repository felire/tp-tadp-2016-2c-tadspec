class TADsPec

    @@resultadosAsserts = []
    @@mayor_a =  Proc.new do |valor|  self > valor end
    @@menor_a = Proc.new do |valor| self < valor end
    @@uno_de_estos = Proc.new do |valor| valor.include? self end

  def self.is_Suite? clase
    clase.instance_methods.any?{|me| is_Test? me}
  end

  def self.is_Test? metodo
    metodo.to_s.start_with?'testear_que_'
  end

  def self.imprimirMierda
     @@resultadosAsserts.each { |a| a.imprimirMierdita}
  end

  def self.agregarAsercionActual booleano
    @@resultadoMetodo.add booleano
  end

  def self.agregarDeberia
    Object.send(:define_method,:deberia) do
    |args| if(args.is_a? Array)
             TADsPec.agregarAsercionActual self.instance_exec(args[1], &args[0])
           else
             TADsPec.agregarAsercionActual self == args
           end
    end
  end

  def self.agregarMetodosSuites clase
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
        #return [Proc.new do return end]
      else
        super(symbol, *args)
      end
    end
  end

  def self.testearMetodo clase , metodo
    instancia = clase.new
    @@resultadoMetodo = ResultadoTest.new
    @@resultadosAsserts = @@resultadosAsserts+[@@resultadoMetodo]
    instancia.send(metodo)
  end

  def self.obtenerListaSuits
    clases = []
    ObjectSpace.each_object(Class).each do
    |valor| clases = clases + [valor]
    end
    listaSuits = clases.select {|clase| TADsPec.is_Suite? clase}
    return listaSuits
  end

  def self.ejecutarTestSuit claseTestear
    instancia = claseTestear.new
    self.agregarMetodosSuites claseTestear
    metodos = instancia.methods(false)
    metodos = metodos.select {|metodo| TADsPec.is_Test? metodo}
    metodos.each {|metodo|
    @@resultadoMetodo = ResultadoTest.new
    @@resultadosAsserts = @@resultadosAsserts+[@@resultadoMetodo]
    instancia.send(metodo)}
  end

  def self.transformar_metodos_testear args
    metodos = []
    args.each {|metodo| metodos = metodos + ['testear_que' + metodo.to_s]}
    return metodos
  end

  def self.testear *args
      self.agregarDeberia
      if(args[0] == nil)
        TADsPec.obtenerListaSuits.each {|suit| TADsPec.ejecutarTestSuit suit}
      end
      if(TADsPec.is_Suite? args[0] && args[1] == nil)
        TADsPec.ejecutarTestSuit args[0]
      end
      if(TADsPec.is_Suite? args[0] && args[1] != nil)
        self.agregarMetodosSuites args[0]
        metodos = TADsPec.transformar_metodos_testear args[1..-1]
        metodos.each{|metodo| TADsPec.testearMetodo args[0], metodo}
      end
    #self.sacarDeberia
    Object.remove_method(:deberia)
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

  def imprimirMierdita
    @resultados.each{ |a| puts a}
  end
end


class Pepe
  def testear_que_asdas
    puts"bien"
  end
end


class Suite
  def testear_que_es_7
    7.deberia ser 7
  end

  def hola
    7.deberia ser 8
    7.deberia ser mayor_a 2
    7.deberia ser mayor_a 8
  end

  def self.testeame
    TADsPec.testear Suite , :testear_que_es_7
  end
end

