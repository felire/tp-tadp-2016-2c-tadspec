class Prueba
  def initialize()
    Object.send(:define_method,:deberia) do
    |args| if(args.is_a? Array)
             puts self.instance_exec(args[1], &args[0])
           else
             puts self == args
           end
    end
    @mayor_a =  Proc.new do |valor|  self > valor end
    @menor_a = Proc.new do |valor| self < valor end
    @uno_de_estos = Proc.new do |valor| valor.include? self end
    @merlusa = 1
  end

  def method_missing(symbol, *args)
    if(symbol.to_s.start_with? 'ser_')
      metodo = symbol.to_s[4..-1] +'?'
      return [Proc.new do |valor| self.send(metodo) end]
    end
    if(symbol.to_s.start_with? 'tener_')
      atributo = '@' + symbol.to_s[6..-1]
      if(args[0].is_a? Array)
        return [Proc.new do |valor| self.instance_variable_get(atributo).instance_exec(args[0][1], &args[0][0]) end]
      else
        return [Proc.new do |valor| self.instance_variable_get(atributo) == args[0] end]
      end
      #return [Proc.new do return end]
    end
  end
  def llamar
    7.deberia ser uno_de_estos [1,5,6,7]
    self.deberia ser_hola
    self.deberia ser 7
  end

  def ser(bloq)
    return bloq
  end
  def mayor_a(valor)
    return [@mayor_a , valor]
  end
  def uno_de_estos(valor)
    return [@uno_de_estos, valor]
  end
  def menor_a(valor)
    return [@menor_a, valor]
  end
  def hola?
    true
  end
  def prueba
    self.deberia tener_merlusa 2
  end
end

puts Prueba.new.prueba



