class Object  # Agrego metodos a object para testear

  attr_accessor :haber_recibidos

  def deberia matcher
    matcher.match self
  end

  def mockear nombreMetodo, &bloque
    cuerpo = self.instance_method(nombreMetodo)
    TADsPec.agregar_mock self, nombreMetodo, cuerpo
    self.send(:define_method, nombreMetodo) do |*args|
      self.instance_exec(args, &bloque)
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

  def encontrar_metodo metodo
    self.haber_recibidos.detect{|haber| haber.metodo == metodo}
  end

  def espiar objeto
    objeto.haber_recibidos = []
    objeto.methods().each{ |metodo|
        metodo_anterior = objeto.method(metodo)
        haber = Haber_recibido.new metodo
        objeto.haber_recibidos = objeto.haber_recibidos + [haber]
        objeto.singleton_class.send(:define_method, metodo) do |*args|
          TADsPec.agregar_metodo_espiado self, metodo, metodo_anterior
          self.encontrar_metodo(metodo).aumentar_veces
          metodo_anterior.call(args)
        end
    }
    objeto
  end

  def veces_utilizadas metodo
    self.encontrar_metodo(metodo).veces_usado
  end

  def haber_recibido metodo
    Haber_recibido.new metodo
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
