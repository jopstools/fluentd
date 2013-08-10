#
# Fluentd
#
# Copyright (C) 2011-2013 FURUHASHI Sadayuki
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module Fluentd

  require 'coolio'

  class Actor
    def initialize
      @loop = Coolio::Loop.new
    end

    attr_reader :loop

    def start
      @thread = Thread.new(&method(:run))
      nil
    end

    def run
      @loop.run
      nil
    rescue
      Fluentd.log.error $!.to_s
      Fluentd.log.error_backtrace
      sleep 1  # TODO auto restart?
      retry
    end

    def stop
      @loop.stop
      nil
    end

    def join
      @thread.join
      nil
    end

    require_relative 'actors/background_actor'
    include Actors::BackgroundActor

    require_relative 'actors/timer_actor'
    include Actors::TimerActor

    require_relative 'actors/io_actor'
    include Actors::IOActor

    require_relative 'actors/socket_actor'
    include Actors::SocketActor

    # TODO not implemented yet
    #require_relative 'actors/async_actor'
    #include Actors::AsyncActor

    module AgentMixin
      def initialize
        @actor = Actor.new
        super
      end

      attr_reader :actor

      def start
        super
        @actor.start
      end

      def stop
        @actor.stop
        @actor.join
        super
      end
    end
  end

end
