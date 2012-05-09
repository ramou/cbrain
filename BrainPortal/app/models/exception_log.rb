
#
# CBRAIN Project
#
# Copyright (C) 2008-2012
# The Royal Institution for the Advancement of Learning
# McGill University
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.  
#

#Exception loggin class
class ExceptionLog < ActiveRecord::Base
  
  Revision_info=CbrainFileRevision[__FILE__]
  
  belongs_to :user
  
  serialize :backtrace 
  serialize :request
  serialize :headers
  serialize :session
  
  #Create an exception record based on exception, user, current request.
  def self.log_exception(exception, user, request)
    params  = request.params
    session = request.session
    hdrs    = request.headers.select { |k| k =~ /^[A-Z]/ }
    
    e = self.new
    e.exception_class = exception.class.to_s
    e.controller      = params[:controller]
    e.action          = params[:action]
    e.method          = request.method.to_s.upcase
    e.format          = request.format.to_sym.to_s
    e.user_id         = user.try(:id)
    e.message         = exception.message
    e.backtrace       = exception.backtrace
    e.request         = {
                          :url         => "#{request.protocol}#{request.env["HTTP_HOST"]}#{request.fullpath}",
                          :parameters  => params.inspect, 
                          :format      => request.format.to_s
                        }
    e.session         = session
    e.headers         = hdrs
    e.instance_name   = CBRAIN::Instance_Name rescue "(?)"
    e.revision_no     = $CBRAIN_StartTime_Revision
    e.save
  end
  
end
