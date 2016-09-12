class TestInitializer

  protected
  def self.agregar_deberia
    Object.send(:define_method,:deberia) do |matcher|
      #TADsPec.agregar_asercion_actual self.instance_exec(args[1], &args[0])
      matcher.match self
    end
  end

  protected
  def self.agregar_mockear
    Object.send(:define_method, :mockear) do |nombreMetodo, &bloque|
      cuerpo = self.instance_method(nombreMetodo)
      TADsPec.agregar_mock self, nombreMetodo, cuerpo
      self.send(:define_method, nombreMetodo) do |*args|
        self.instance_exec(args,&bloque)
      end
    end
  end

  def self.inicializar_tests
    self.agregar_deberia
    self.agregar_mockear
  end

  def self.finalizar_tests
    Object.send(:remove_method,:deberia)
    Object.send(:remove_method,:mockear)
  end

  def self.agregar_metodos_a_suite instancia

      instancia.singleton_class.send(:define_method,:mayor_a) do |valor|
        Mayor_a.new valor
      end

      instancia.singleton_class.send(:define_method,:menor_a) do |valor|
        Menor_a.new valor
      end

      instancia.singleton_class.send(:define_method,:uno_de_estos) do |valor|
        Uno_de_estos.new valor
      end

      instancia.singleton_class.send(:define_method,:ser) do |valor|
       Ser.new valor
      end

      instancia.singleton_class.send(:define_method, :entender) do |mensaje|
        Entender.new mensaje
      end

      instancia.singleton_class.send(:define_method, :explotar_con) do |excepcion|
        Explotar_con.new excepcion
      end

      instancia.singleton_class.send(:define_method,:method_missing) do |symbol,*args|
        if(symbol.to_s.start_with? 'ser_')
          metodo = symbol.to_s[4..-1] +'?'
          return Ser_.new metodo
        end
        if(symbol.to_s.start_with? 'tener_')
          atributo = '@' + symbol.to_s[6..-1]
          if args[0].respond_to? :match
            return Tener_.new atributo, args[0]
          else
            matcher = Ser.new args[0]
            return Tener_.new atributo, matcher
          end
        end
          super(symbol, *args)
      end
    end
end