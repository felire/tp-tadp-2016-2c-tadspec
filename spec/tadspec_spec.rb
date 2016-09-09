require 'rspec'
require './tadspec.rb'
describe 'Metodos de Prueba' do
  it 'Deberia ser suit' do
    class Suite
    def testear_que_dice_bien
      puts"bien"
    end
    end
    expect(TADsPec.is_suite? Suite).to equal(true)
  end
  it 'Deberia pasar el test' do
    class Suite
      def testear_que_es_7
        7.deberia ser 7
      end
    end
    instancia = Suite.new
    TestInitializer.inicializar_tests
    TestInitializer.agregar_metodos_a_suite instancia
    expect(TADsPec.testear_metodo(instancia, :testear_que_es_7).paso_test?).to equal(true)
    TestInitializer.finalizar_tests
  end
  it 'Deberia fallar el test' do
    class Suite
      def testear_que_2_mayor_a_3
        #7.deberia ser 8
        2.deberia ser mayor_a 3
        #7.deberia ser mayor_a 8
      end
    end
    instancia = Suite.new
    TestInitializer.inicializar_tests
    TestInitializer.agregar_metodos_a_suite instancia
    expect(TADsPec.testear_metodo(instancia, :testear_que_2_mayor_a_3).paso_test?).to equal(false)
    TestInitializer.finalizar_tests
  end
  it 'Deberia pasar el test' do
    class Suite
      def testear_que_2_menor_a_3
        #7.deberia ser 8
        2.deberia ser mayor_a 3
        #7.deberia ser mayor_a 8
      end
    end
    instancia = Suite.new
    TestInitializer.inicializar_tests
    TestInitializer.agregar_metodos_a_suite instancia
    expect(TADsPec.testear_metodo(instancia, :testear_que_2_menor_a_3).paso_test?).to equal(false)
    TestInitializer.finalizar_tests
  end
end






#Tests



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
