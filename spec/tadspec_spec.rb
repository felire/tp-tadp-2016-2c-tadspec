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
    expect(TADsPec.testear_metodo instancia, :testear_que_es_7).to equal(true)
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
    expect(TADsPec.testear_metodo instancia, :testear_que_2_mayor_a_3).to equal(false)
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
    expect(TADsPec.testear_metodo instancia, :testear_que_2_menor_a_3).to equal(false)
  end


  it 'Deberia ser uno de esos' do
    class Ser_o_no_ser
      def testear_que_true
        22.deberia ser uno_de_estos [7, 22, "hola"]
      end
    end
    instancia = Ser_o_no_ser.new
    expect(TADsPec.testear_metodo instancia, :testear_que_true).to equal(true)
  end


  it 'No deberia ser uno de esos' do
    class Ser_o_no_ser
      def testear_que_true
        23.deberia ser uno_de_estos [7, 22, "hola"]
      end
    end
    instancia = Ser_o_no_ser.new
    expect(TADsPec.testear_metodo instancia, :testear_que_true).to equal(false)
  end

  it 'Deberia ser todo' do
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
    class SuitePrueba

      def initialize
        @nico = Persona.new
        @nico.set 30
        @leandro = Persona.new
        @leandro.set 22

      end

      def testear_que_holis
        @nico.deberia ser_viejo    # pasa: Nico tiene edad 30. #@nico.viejo?.deberia ser true
        @leandro.deberia tener_nombre nil # pasa
        @leandro.deberia tener_edad mayor_a 20 # pasa
        @leandro.deberia tener_edad menor_a 25 # pasa
      end
    end
    instancia = SuitePrueba.new
    expect(TADsPec.testear_metodo instancia, :testear_que_holis).to equal(true)
  end


  it 'No deberia ser todo' do
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
    class SuitePrueba

      def initialize
        @nico = Persona.new
        @nico.set 30
        @leandro = Persona.new
        @leandro.set 22

      end

      def testear_que_holis
        @nico.deberia ser_viejo    # pasa: Nico tiene edad 30. #@nico.viejo?.deberia ser true
        @leandro.deberia tener_nombre 'a' # pasa
        @leandro.deberia tener_edad mayor_a 20 # pasa
        @leandro.deberia tener_edad menor_a 25 # pasa
      end
    end
    instancia = SuitePrueba.new
    expect(TADsPec.testear_metodo instancia, :testear_que_holis).to equal(false)
  end


  it 'Deberia entender' do
    class SuitePrueba

      def testear_que_entiende_new
        Object.deberia entender :new
      end
    end
    instancia = SuitePrueba.new
    expect(TADsPec.testear_metodo instancia, :testear_que_entiende_new).to equal(true)
  end
  it 'No deberia entender' do
    class SuitePrueba

      def testear_que_no_entiende_new
        Object.deberia entender :pepe
      end
    end
    instancia = SuitePrueba.new
    expect(TADsPec.testear_metodo instancia, :testear_que_no_entiende_new).to equal(false)
  end


  it 'Deberia Explotar' do
    class SuitePrueba

      def testear_que_explota
        procedimiento = Proc.new do 7/0 end
        procedimiento.deberia explotar_con ZeroDivisionError
      end
    end
    instancia = SuitePrueba.new
    expect(TADsPec.testear_metodo instancia, :testear_que_explota).to equal(true)
  end


  it 'No deberia Explotar' do
    class SuitePrueba2

      def testear_que_no_explota
        procedimiento = Proc.new do 7/1 end
        procedimiento.deberia explotar_con ZeroDivisionError
      end
    end
    instancia = SuitePrueba2.new
    expect(TADsPec.testear_metodo instancia, :testear_que_no_explota).to equal(false)
  end

  it 'Deberia estar mockeada' do
    class Numero
      def dameNumero
        0
      end
    end
      class SuiteMock
        def testear_que_mockea
          Numero.mockear(:dameNumero) do
            1
          end
          num = Numero.new
          num.dameNumero.deberia ser 1
        end
      end

    instancia = SuiteMock.new
    expect(TADsPec.testear_metodo instancia, :testear_que_mockea).to equal(true)
  end


  it 'Deberia testearnos a nosotros' do
    class Prueba
      def testear_que_true
      7.deberia ser 7
      end
    end

    class Testeador
      def testear_que_testea_bien
      instancia = Prueba.new
      (TADsPec.testear_metodo instancia, :testear_que_true).deberia ser true
      end
    end
    instancia = Testeador.new
    expect(TADsPec.testear_metodo instancia, :testear_que_testea_bien).to equal(true)
  end

  it 'Prueba spies' do
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
      def a
        puts 'chau'
      end
      def m var
        self.a
        puts var
      end

      def metodin var1, var2
        puts var1
        puts var2
      end
    end

    class SpyTest
      def testear_que_anda
        persona = Persona.new
        persona = espiar(persona)
        persona.m 'holis'
        persona.m 'holis'
        persona.metodin 'como', 'va'
        persona.deberia haber_recibido(:m).veces(2)
        persona.deberia haber_recibido(:metodin).con_argumentos('como', 'va')
        persona.deberia haber_recibido(:m)
      end

      def testear_que_falla
        persona= Persona.new
        persona = espiar(persona)
        persona.m 'holis'
        persona.m 'holis'
        persona.deberia haber_recibido(:m).con_argumentos('holis','merlusa')
        persona.deberia haber_recibido(:s)
      end
    end

    instancia = SpyTest.new
    expect(TADsPec.testear_metodo instancia, :testear_que_anda).to equal(true)
    expect(TADsPec.testear_metodo instancia, :testar_que_falla).to equal(false)
  end

end