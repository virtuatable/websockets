module Controllers
  # Controller handling the websockets, creating it and receiving the commands for it.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Websockets < Arkaan::Utils::ControllerWithoutFilter
    declare_route 'get', '/' do
      session = check_session 'messages'
      application = check_application 'messages'
      
      if !request.websocket?
        custom_error 400, 'creation.websocket.invalid_type'
      else
        request.websocket do |ws|
          Services::Websockets.instance.create(session.id.to_s, ws)
        end
      end
    end

    declare_route 'post', '/messages' do
      application = check_application 'messages'
      session = check_session 'messages'
      check_presence 'message', 'receiver', route: 'messages'

      EM.next_tick do
        Services::Websockets.instance.send_to_user(params['receiver'], params['message'], params['data'] || {})
      end
      halt 200, {message: 'transmitted'}.to_json
    end
  end
end