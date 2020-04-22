defmodule ProtoValidator.Protoc.Template do
  @moduledoc false
  @msg_tmpl Path.expand("./templates/message.ex.eex", :code.priv_dir(:proto_validator))

  require EEx

  EEx.function_from_file(:def, :message, @msg_tmpl, [:name, :options, :fields], trim: true)
end
