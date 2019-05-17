require 'spec_helper'

describe 'infiniband::calc_log_num_mtt' do
  it 'should return 23' do
    is_expected.to run.with_params(135303601848.32).and_return(23)
  end

  it 'should return 22' do
    is_expected.to run.with_params(67528032256.00).and_return(22)
  end

  it 'should return 25' do
    is_expected.to run.with_params(135303601848.32, 1).and_return(25)
  end

  it 'should return 24' do
    is_expected.to run.with_params(67528032256.00, 1).and_return(24)
  end

  it 'should handle [undef,1]' do
    is_expected.to run.with_params(nil, 1).and_return(0)
  end

  it 'should raise a ParseError if there is less than 1 argument' do
    expect { scope.function_calc_log_num_mtt([]).to raise_error(Puppet::ParseError, /Takes at least one args, but 0 given./) }
  end
  
  it 'should raise a ParseError if there is more than 3 argument' do
    expect { scope.function_calc_log_num_mtt(['1','2','3','4']).to raise_error(Puppet::ParseError, /Takes at most three args, but 4 given./) }
  end
end
