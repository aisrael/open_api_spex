defmodule OpenApiSpexTest.PetController do
  @moduledoc ["pets"]

  use Phoenix.Controller
  use OpenApiSpex.Controller
  alias OpenApiSpex.{Operation, Schema}
  alias OpenApiSpexTest.Schemas

  plug OpenApiSpex.Plug.CastAndValidate

  @doc """
  Show pet.

  Show a pet by ID.
  """
  @def parameters: [
         id: [
           in: :path,
           type: %Schema{type: :integer, minimum: 1},
           description: "Pet ID",
           example: 123
         ]
       ],
       responses: [
         ok: {"Pet", "application/json", Schemas.PetResponse}
       ]
  def show(conn, %{id: _id}) do
    json(conn, %Schemas.PetResponse{
      data: %Schemas.Dog{
        pet_type: "Dog",
        bark: "woof"
      }
    })
  end

  def index(conn, _params) do
    json(conn, %Schemas.PetsResponse{
      data: [
        %Schemas.Dog{
          pet_type: "Dog",
          bark: "joe@gmail.com"
        }
      ]
    })
  end

  @doc """
  Create pet.

  Create a pet.
  """
  @doc request_body:
         {"The pet attributes", "application/json", Schemas.PetRequest, required: true},
       responses: [
         created: {"Pet", "application/json", Schemas.PetRequest}
       ]
  def create(conn, _) do
    %Schemas.PetRequest{pet: pet} = Map.get(conn, :body_params)

    json(conn, %Schemas.PetResponse{
      data: pet
    })
  end

  @doc """
  Adopt pet.

  Adopt a pet.
  """
  @doc parameters: [
         {:"x-user-id",
          in: :header,
          type: :string,
          description: "User that performs this action",
          required: true},
         id: [
           in: :path,
           type: %Schema{type: :integer, minimum: 1},
           description: "Pet ID",
           example: 123
         ],
         status: [in: :query, type: Schemas.PetStatus, description: "New status"],
         debug: [
           in: :cookie,
           type: %Schema{type: :integer, enum: [0, 1], default: 0},
           description: "Debug"
         ]
       ],
       responses: [
         ok: {"Pet", "application/json", Schemas.PetResponse}
       ]
  def adopt(conn, %{:"x-user-id" => _user_id, :id => _id, :debug => 0}) do
    json(conn, %Schemas.PetResponse{
      data: %Schemas.Dog{
        pet_type: "Dog",
        bark: "woof"
      }
    })
  end

  def adopt(conn, %{:"x-user-id" => _user_id, :id => _id, :debug => 1}) do
    json(conn, %Schemas.PetResponse{
      data: %Schemas.Dog{
        pet_type: "Debug-Dog",
        bark: "woof"
      }
    })
  end

  @doc """
  Create pet.

  Create a pet.
  """
  @doc request_body:
         {"The pet attributes", "application/json", Schemas.PetAppointmentRequest, required: true},
       responses: [
         created: {"Pet", "application/json", Schemas.PetResponse}
       ]
  def appointment(conn, _) do
    json(conn, %Schemas.PetResponse{
      data: [%{pet_type: "Dog", bark: "bow wow"}]
    })
  end
end
