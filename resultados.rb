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
