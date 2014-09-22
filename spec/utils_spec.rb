require_relative "../my_strategy/utils"

describe Utils do
  describe '#angles_diff' do
    subject { described_class.angles_diff(a1, a2) }
    let(:first_quarter) { -Math::PI/4 }
    let(:second_quarter) { -3*Math::PI/4 }
    let(:third_quarter) { 3*Math::PI/4 }
    let(:fourth_quarter) { Math::PI/4 }
    context 'a1 in I' do
      let(:a1) { first_quarter }
      context 'when a2 in I' do
        context 'when a2 closer to 0' do
          let(:a2) { first_quarter+0.1 }
          it 'returns positive angle' do
            expect(subject).to be > 0
          end
        end
        context 'when a2 closer to -PI/2' do
          let(:a2) { first_quarter-0.1 }
          it 'returns negative angle' do
            expect(subject).to be < 0
          end
        end
      end
      context 'when a2 in II' do
        let(:a2) { second_quarter }
        it 'returns negative angle' do
          expect(subject).to eq -Math::PI/2
        end
      end
      context 'when a2 in III' do
        context 'when a2 closer to 0' do
          let(:a2) { third_quarter-0.1 }
          it 'returns negative angle' do
            expect(subject).to eq (Math::PI-0.1)
          end
        end
        context 'when a2 closer to PI' do
          let(:a2) { third_quarter+0.1 }
          it 'returns positive angle' do
            expect(subject).to eq (-Math::PI+0.1)
          end
        end
      end
      context 'when a2 in VI' do
        let(:a2) { fourth_quarter }
        it 'returns positive angle' do
          expect(subject).to eq Math::PI/2
        end
      end
    end
    context 'when a1 in II' do
      let(:a1) { second_quarter }
      context 'when a2 in I' do
        let(:a2) { first_quarter }
        it 'returns positive angle' do
          expect(subject).to eq Math::PI/2
        end
      end
      context 'when a2 in II' do
        context 'when a2 closer to -PI/2' do
          let(:a2) { second_quarter+0.1 }
          it 'returns positive angle' do
            expect(subject).to be > 0
          end
        end
        context 'when a2 closer to -PI' do
          let(:a2) { second_quarter-0.1 }
          it 'returns negative angle' do
            expect(subject).to be < 0
          end
        end
      end
      context 'when a2 in III' do
        let(:a2) { third_quarter }
        it 'returns negative angle' do
          expect(subject).to eq -Math::PI/2
        end
      end
      context 'when a2 in IV' do
        context 'when a2 closer to 0' do
          let(:a2) { fourth_quarter-0.1 }
          it 'returns positive angle' do
            expect(subject).to eq Math::PI-0.1
          end
        end
        context 'when a2 closer to PI/2' do
          let(:a2) { fourth_quarter+0.1 }
          it 'returns negative angle' do
            expect(subject).to eq -Math::PI+0.1
          end
        end
      end
    end
    context 'when a1 in III' do
      let(:a1) { third_quarter }
      context 'when a2 in I' do
        context 'when a2 closer to 0' do
          let(:a2) { first_quarter+0.1 }
          it 'returns negative angle' do
            expect(subject).to eq -Math::PI+0.1
          end
        end
        context 'when a2 closer to -PI/2' do
          let(:a2) { first_quarter-0.1 }
          it 'returns positive angle' do
            expect(subject).to eq Math::PI-0.1
          end
        end
      end
      context 'when a2 in II' do
        let(:a2) { second_quarter }
        it 'returns positive angle' do
          expect(subject).to eq Math::PI/2
        end
      end
      context 'when a2 in III' do
        context 'when a2 closer to PI/2' do
          let(:a2) { third_quarter-0.1 }
          it 'returns negative angle' do
            expect(subject).to be < 0
          end
        end
        context 'when a2 closer to PI' do
          let(:a2) { third_quarter+0.1 }
          it 'returns positive angle' do
            expect(subject).to be > 0
          end
        end
      end
      context 'when a2 in IV' do
        let(:a2) { fourth_quarter }
        it 'returns negative angle' do
          expect(subject).to eq -Math::PI/2
        end
      end
    end
    context 'when a1 in VI' do
      let(:a1) { fourth_quarter }
      context 'when a2 in I' do
        let(:a2) { first_quarter }
        it 'returns negative angle' do
          expect(subject).to eq -Math::PI/2
        end
      end
      context 'when a2 in II' do
        context 'when a2 closer to -PI/2' do
          let(:a2) { second_quarter+0.1 }
          it 'returns negative angle' do
            expect(subject).to eq -Math::PI+0.1
          end
        end
        context 'when a2 closer to -PI' do
          let(:a2) { second_quarter-0.1 }
          it 'returns positive angle' do
            expect(subject).to eq Math::PI-0.1
          end
        end
      end
      context 'when a2 in III' do
        let(:a2) { third_quarter }
        it 'returns positive angle' do
          expect(subject).to eq Math::PI/2
        end
      end
      context 'when a2 in IV' do
        context 'when a2 closer to 0' do
          let(:a2) { fourth_quarter-0.1 }
          it 'returns negative angle' do
            expect(subject).to be < 0
          end
        end
        context 'when a2 closer to PI/2' do
          let(:a2) { fourth_quarter+0.1 }
          it 'returns positive angle' do
            expect(subject).to be > 0
          end
        end
      end
    end
  end

end
