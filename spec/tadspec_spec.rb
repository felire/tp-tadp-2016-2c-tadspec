require 'rspec'
require './tadspec.rb'
describe 'TADsPec' do

  it 'should El test corrio bien' do
    class Suite
    def testear_que_dice_bien
      puts"bien"
    end
    end
    TADsPec.is_Suite? Suite
  end
  it 'should El test corrio bien' do
    class Suite
      def testear_que_es_7
        7.deberia ser 7
      end
    end
    TADsPec.testear Suite , :testear_que_es_7
    TADsPec.imprimirMierda
  end
  end