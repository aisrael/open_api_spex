defmodule OpenApiSpex.Decimal do
  @moduledoc """
  A highly simplified and opinionated decimal type with very limited functionality, mainly
  just used to implement `multipleOf` validation for Open API `number` types.
  """
  alias __MODULE__

  defstruct sign: 1, coef: 0, exp: 0

  @type t :: %__MODULE__{sign: integer(), coef: integer(), exp: integer()}

  @doc """
  Construct a Decimal from an integer or float. If given a float, uses the String representation
  of the float then parses it. If given an integer, merely uses the integer as the coefficent
  with an exp of `0`.
  """
  @spec new(n :: integer() | float()) :: Decimal.t()
  def new(n) when is_integer(n) do
    if n < 0 do
      %Decimal{sign: -1, coef: n, exp: 0}
    else
      %Decimal{sign: 1, coef: n, exp: 0}
    end
  end

  def new(n) when is_float(n) do
    parse(Float.to_string(n))
  end

  @doc """
  Constructs a `Decimal` value out of a sign (must be an integer, will be 'coerced' to 1 or -1),
  a positive integer coefficient and an integer exponent.
  """
  @spec new(sign :: integer, coef :: non_neg_integer, exp :: integer) :: Decimal.t()
  def new(sign, coef, exp) when coef >= 0 do
    plus_or_minus_one = if sign < 0, do: -1, else: 1
    %Decimal{sign: plus_or_minus_one, coef: coef, exp: exp}
  end

  @doc """
  Parses a string into a `Decimal` value. Returns `{Decimal, remainder}` on success, otherwise `:error`.
  """
  @spec parse(s :: String.t()) :: Decimal.t() | :error
  def parse(s) when is_binary(s) do
    with {sign, int, rem} <- pre_parse(s) do
      sign =
        if sign == "-" do
          -1
        else
          1
        end

      case rem do
        "" ->
          with {int, ""} <- Integer.parse(int) do
            Decimal.new(sign, int, 0)
          end

        "." <> rem ->
          exp = -String.length(rem)

          with {int, ""} <- Integer.parse(int <> rem) do
            Decimal.new(sign, int, exp)
          end

        _ ->
          :error
      end
    end
  end

  @decimal_pattern ~r/^(-?)([[:digit:]]+)(\.[[:digit:]]+)?$/

  @spec pre_parse(s :: String.t()) :: {String.t(), String.t(), String.t()} | :error
  defp pre_parse(s) do
    case Regex.run(@decimal_pattern, s) do
      [_, sign, int] ->
        {sign, int, ""}

      [_, sign, int, rem] ->
        {sign, int, rem}

      nil ->
        :error
    end
  end

  @doc """
  Compares two Decimal values for mathematical equality and returns `true` if they are
  equal, otherwise `false`.
  """
  @spec equal?(Decimal.t(), Decimal.t()) :: boolean
  def equal?(x, y) do
    with true <- x.sign == y.sign do
      {nx, ny} = normalize(x, y)
      nx.coef == ny.coef
    end
  end

  @doc """
  'Normalizes' a pair of `Decimal` values by setting their exponents to the same (the lower)
  value.
  """
  @spec normalize(Decimal.t(), Decimal.t()) :: {Decimal.t(), Decimal.t()}
  def normalize(
        %Decimal{sign: sign_x, coef: coef_x, exp: exp_x} = x,
        %Decimal{sign: sign_y, coef: coef_y, exp: exp_y} = y
      ) do
    cond do
      exp_y > exp_x ->
        {x, %Decimal{sign: sign_y, coef: pow10(coef_y, exp_y - exp_x), exp: exp_x}}

      exp_x > exp_y ->
        {%Decimal{sign: sign_x, coef: pow10(coef_x, exp_x - exp_y), exp: exp_y}, y}

      true ->
        {x, y}
    end
  end

  # We don't handle raising to negative exponents
  defp pow10(x, pow) when pow > 0, do: 10 * pow10(x, pow - 1)
  defp pow10(x, _), do: x

  @doc """
  Checks if the first `Decimal` is a "multiple of" the second `Decimal`. That is, a decimal number
  `n` is a multiple of `d` if there exists an integer `x` such that `x * d == n`.

  This function works by first calling `normalize/2` to normalize the exponents of both decimals.
  It then disregards the sign (`n`, even if negative, is a "multiple of" `d` if `|n|` is a multiple `d`),
  and then merely checks if the coefficient of `n` is evenly divisible by the coefficient of `d`
  (`rem(coef_n, coef_d) == 0`).
  """
  @spec multiple_of?(Decimal.t(), Decimal.t()) :: boolean
  def multiple_of?(%Decimal{} = n, %Decimal{} = d) do
    {%Decimal{coef: coef_n}, %Decimal{coef: coef_d}} = normalize(n, d)
    rem(coef_n, coef_d) == 0
  end
end
