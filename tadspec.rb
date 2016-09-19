require './test_initializer.rb'
require './resultados.rb'

class Mock
  attr_accessor :clase, :metodo, :cuerpo

  def restaurar
    clase.send(:define_method, metodo, cuerpo)
  end
end


class Metodo_espiado
  attr_accessor :objeto, :metodo, :parametros
end


class TADsPec

  @@mocks = []
  @@metodos_espiados = []

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
    listaSuits = clases.select {|clase| TADsPec.is_suite? clase}
    return listaSuits
  end

  def self.agregar_metodo_espiado objeto, metodo, parametros
    met_espiado = Metodo_espiado.new
    met_espiado.objeto= objeto
    met_espiado.metodo= metodo
    met_espiado.parametros= parametros
    @@metodos_espiados = @@metodos_espiados+[met_espiado]
  end

  def self.obtener_metodos_espiados obj
    @@metodos_espiados.select{|metodo| metodo.objeto == obj}
  end

  def self.agregar_mock clase, metodo, cuerpo
    mockNvo = Mock.new
    mockNvo.clase= clase
    mockNvo.metodo= metodo
    mockNvo.cuerpo= cuerpo
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
    begin
      instancia.send(metodo)
      TADsPec.borrar_mocks
      @@metodos_espiados = []
      Gestionador_resultados.instance.fin_metodo metodo
    rescue Exception=>e
      Gestionador_resultados.instance.test_explotado metodo,e
    end
  end

  def self.ejecutar_test_suite claseATestear
    metodos = claseATestear.new.methods
    metodos = metodos.select {|metodo| TADsPec.is_test? metodo}
    metodos.each {|metodo|
      instancia = claseATestear.new
      TADsPec.testear_metodo instancia, metodo }
  end

  def self.testear *args
    if(args[0] == nil)
      TADsPec.obtener_lista_suites.each {|suit| TADsPec.ejecutar_test_suite suit}
    elsif((TADsPec.is_suite? args[0]) && args[1] == nil)
      self.ejecutar_test_suite args[0]
    elsif((TADsPec.is_suite? args[0]) && args[1] != nil)
      metodos = TADsPec.transformar_metodos_testear args[1..-1]
      metodos.each{|metodo|
        instancia = args[0].new
        TADsPec.testear_metodo instancia, metodo}
    end
    Gestionador_resultados.instance.mostrar_resultados
    return
  end
end