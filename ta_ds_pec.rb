class TADsPec
  def self.is_Suite? clase
    clase.instance_methods.any?{|me| is_Test? me}
  end
  def self.is_Test? metodo
    metodo.to_s.start_with?'testear_que_'
  end
end
class ContextoTest #Cada test ejecuta aca adentro, hay uno por test
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
end
class Pepe
  def testear_que_asdas
    puts"bien"
  end
end