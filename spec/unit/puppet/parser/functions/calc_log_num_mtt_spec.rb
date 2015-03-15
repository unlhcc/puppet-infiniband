require 'spec_helper'

describe 'the calc_log_num_mtt function' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    expect(Puppet::Parser::Functions.function('calc_log_num_mtt')).to eq('function_calc_log_num_mtt')
  end

  it 'should return 23 when args [129035.57]' do
    expect(scope.function_calc_log_num_mtt(['129035.57'])).to eq(23)
  end

  it 'should return 22 when args [64399.75]' do
    expect(scope.function_calc_log_num_mtt(['64399.75'])).to eq(22)
  end

  it 'should return 25 when args [129035.57,1]' do
    expect(scope.function_calc_log_num_mtt(['129035.57','1'])).to eq(25)
  end

  it 'should return 24 when args [64399.75,1]' do
    expect(scope.function_calc_log_num_mtt(['64399.75','1'])).to eq(24)
  end

  it 'should handle [undef,1]' do
    expect(scope.function_calc_log_num_mtt([nil,'1'])).to eq(0)
  end

  it 'should raise a ParseError if there is less than 1 argument' do
    expect { scope.function_calc_log_num_mtt([]).to raise_error(Puppet::ParseError, /Takes at least one args, but 0 given./) }
  end
  
  it 'should raise a ParseError if there is more than 3 argument' do
    expect { scope.function_calc_log_num_mtt(['1','2','3','4']).to raise_error(Puppet::ParseError, /Takes at most three args, but 4 given./) }
  end
end
