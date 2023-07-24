# frozen_string_literal: true

module MongoDB
  module Protocol
    # https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/#request-opcodes
    module OpCodes
      OP_REPLY = 1
      OP_UPDATE = 2001
      OP_INSERT = 2002
      RESERVED  = 2003
      OP_QUERY  = 2004
      OP_GET_MORE = 2005
      OP_DELETE = 2006
      OP_KILL_CURSORS = 2007
      OP_COMPRESSED = 2012
      OP_MSG = 2013
    end
  end
end
