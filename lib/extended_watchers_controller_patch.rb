require_dependency 'watchers_controller'

module ExtendedWatchersControllerPatch
    
    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :original_autocomplete_for_user, :autocomplete_for_user
            alias_method :autocomplete_for_user, :patched_autocomplete_for_user
        end
    end

    module InstanceMethods

        def patched_autocomplete_for_user
          @users = User.active.sorted.like(params[:q]).limit(100).all
          @users = @users.reject {|user| !user.allowed_to?(:view_issues, @project)}
          if @watched
            @users -= @watched.watcher_users
          end
          render :layout => false
        end

    end

end

