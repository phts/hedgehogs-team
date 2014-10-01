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

  describe '#moves_back?' do
    subject { described_class.moves_back?(unit) }
    let(:unit) { double(:unit) }
    before :each do
      allow(unit).to receive(:angle).and_return(unit_angle)
      allow(described_class).to receive(:speed_vector_angle).with(unit).and_return(speed_angle)
    end
    context 'if diff between unit angle and speed angle is more than 90 deg' do
      let(:unit_angle) { Math::PI/4 }
      let(:speed_angle) { Math::PI - 0.1 }
      it 'returns true' do
        expect(subject).to eq true
      end
    end
    context 'if diff between unit angle and speed angle is less than 90 deg' do
      let(:unit_angle) { -Math::PI/4 }
      let(:speed_angle) { -Math::PI/2 }
      it 'returns false' do
        expect(subject).to eq false
      end
    end
  end

end
