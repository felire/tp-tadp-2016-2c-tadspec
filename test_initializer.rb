class TestInitializer
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

  @@explotar_con = Proc.new do |valor|
        resultado = ResultadoAssert.new
        begin
            self.call
            resultado.set_descripcion 'FALLO: el bloque no genero excepcion'
            resultado.set_resultado 2
          rescue Exception=>e
                   if(e.class==valor)
                              resultado.set_descripcion'El resultado fue el esperado: el bloque fallo con la exceocion ' + valor.to_s
                              resultado.set_resultado 1
                            else
                                       resultado.set_descripcion'FALLO: el bloque fallo con otra excepcion'
                                       resultado.set_resultado 2
                                     end
                 end
        resultado
      end

  protected
  def self.agregar_deberia
    BasicObject.send(:define_method,:deberia) do |args|
      TADsPec.agregar_asercion_actual self.instance_exec(args[1], &args[0])
    end
  end
  protected
  def self.agregar_mockear
    BasicObject.send(:define_method, :mockear) do |nombreMetodo, &bloque|
      cuerpo = self.instance_method(nombreMetodo)
      TADsPec.agregar_mock self, nombreMetodo, cuerpo
      self.send(:define_method, nombreMetodo) do
        self.instance_exec(&bloque)
      end
    end
  end
  def self.inicializar_tests
    self.agregar_deberia
    self.agregar_mockear
  end
  def self.finalizar_tests
    BasicObject.send(:remove_method,:deberia)
    BasicObject.send(:remove_method,:mockear)
  end
  def self.agregar_metodos_a_suite instancia

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

      instancia.singleton_class.send(:define_method, :explotar_con) do |excepcion|
        return[@@explotar_con,excepcion]
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
end