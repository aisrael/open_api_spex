defmodule OpenApiSpex.DecimalTest do
  use ExUnit.Case
  alias OpenApiSpex.Decimal

  describe "parse" do
    test "it can parse proper decimal numbers" do
      assert %Decimal{sign: 1, coef: 0, exp: 0} = Decimal.parse("0")
      assert %Decimal{sign: -1, coef: 1, exp: 0} = Decimal.parse("-1")
      assert %Decimal{sign: 1, coef: 42, exp: 0} = Decimal.parse("42")
      assert %Decimal{sign: 1, coef: 1, exp: -1} = Decimal.parse("0.1")
      assert %Decimal{sign: 1, coef: 12, exp: -1} = Decimal.parse("1.2")
      assert %Decimal{sign: 1, coef: 120, exp: -2} = Decimal.parse("1.20")
    end
  end

  describe "equal?" do
    test "it works" do
      ten = %Decimal{sign: 1, coef: 10, exp: 0}
      assert Decimal.equal?(ten, %Decimal{sign: 1, coef: 10, exp: 0})
      assert Decimal.equal?(ten, %Decimal{sign: 1, coef: 1, exp: 1})
      assert Decimal.equal?(%Decimal{sign: 1, coef: 1, exp: 1}, ten)
      assert Decimal.equal?(ten, %Decimal{sign: 1, coef: 100, exp: -1})
      assert Decimal.equal?(%Decimal{sign: 1, coef: 100, exp: -1}, ten)

      zero_point_two = %Decimal{sign: 1, coef: 2, exp: -1}
      assert Decimal.equal?(zero_point_two, %Decimal{sign: 1, coef: 2, exp: -1})
      assert Decimal.equal?(zero_point_two, %Decimal{sign: 1, coef: 20, exp: -2})
      assert Decimal.equal?(%Decimal{sign: 1, coef: 20, exp: -2}, zero_point_two)

      assert Decimal.equal?(Decimal.parse("-1.2"), Decimal.parse("-1.200"))
    end
  end

  describe "normalize" do
    test "it works" do
      ten = %Decimal{sign: 1, coef: 10, exp: 0}
      assert {ten, ten} == Decimal.normalize(ten, %Decimal{sign: 1, coef: 10, exp: 0})
      assert {ten, ten} == Decimal.normalize(ten, %Decimal{sign: 1, coef: 1, exp: 1})
      assert {ten, ten} == Decimal.normalize(%Decimal{sign: 1, coef: 1, exp: 1}, ten)

      assert {%Decimal{sign: 1, coef: 100, exp: -1}, %Decimal{sign: 1, coef: 100, exp: -1}} ==
               Decimal.normalize(ten, %Decimal{sign: 1, coef: 100, exp: -1})

      assert {%Decimal{sign: 1, coef: 100, exp: -1}, %Decimal{sign: 1, coef: 100, exp: -1}} ==
               Decimal.normalize(%Decimal{sign: 1, coef: 100, exp: -1}, ten)

      zero_point_two = %Decimal{sign: 1, coef: 2, exp: -1}

      assert {zero_point_two, zero_point_two} =
               Decimal.normalize(zero_point_two, %Decimal{sign: 1, coef: 2, exp: -1})

      assert {zero_point_two, zero_point_two} =
               Decimal.normalize(zero_point_two, %Decimal{sign: 1, coef: 20, exp: -2})

      assert {zero_point_two, zero_point_two} =
               Decimal.normalize(%Decimal{sign: 1, coef: 20, exp: -2}, zero_point_two)
    end
  end

  describe "multiple_of?" do
    test "it works" do
      assert Decimal.multiple_of?(Decimal.new(4), Decimal.new(2))
      assert Decimal.multiple_of?(Decimal.parse("1.2"), Decimal.parse("0.4"))
      assert Decimal.multiple_of?(Decimal.parse("1.20"), Decimal.parse("0.4"))
      assert Decimal.multiple_of?(Decimal.parse("1.2"), Decimal.parse("0.40"))
      assert Decimal.multiple_of?(Decimal.parse("-1.2"), Decimal.parse("0.4"))
      assert Decimal.multiple_of?(Decimal.parse("1.2"), Decimal.parse("-0.4"))
    end
  end
end
