class Object  #Agrego metodos a object para testear
  def deberia matcher
    matcher.match self
  end
  def mockear nombreMetodo,&bloque
    cuerpo = self.instance_method(nombreMetodo)
    TADsPec.agregar_mock self, nombreMetodo, cuerpo
    self.send(:define_method, nombreMetodo) do |*args|
      self.instance_exec(args,&bloque)
    end
  end
    def mayor_a valor
      Mayor_a.new valor
    end
    def menor_a valor
      Menor_a.new valor
    end
    def uno_de_estos valor
      Uno_de_estos.new valor
    end
    def ser valor
      Ser.new valor
    end
    def entender mensaje
      Entender.new mensaje
    end
    def explotar_con excepcion
      Explotar_con.new excepcion
    end
  def method_missing symbol,*args
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