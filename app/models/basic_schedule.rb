#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  TSDBExplorer is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#  Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with TSDBExplorer.  If not, see <http://www.gnu.org/licenses/>.
#
#  $Id$
#

class BasicSchedule < ActiveRecord::Base

  has_many :locations, :primary_key => :uuid, :foreign_key => :basic_schedule_uuid, :dependent => :delete_all

  scope :runs_on_by_uid, lambda { |uid,date| where('train_uid = ? AND ? BETWEEN runs_from AND runs_to', uid, date).order("runs_to - runs_from").limit(1) }
  scope :runs_on_by_train_identity, lambda { |identity,date| where('train_identity_unique = ? AND ? BETWEEN runs_from AND runs_to', uid, date).order("runs_to - runs_from").limit(1) }

  def origin
    self.locations.first
  end

  def terminate
    self.locations.last
  end

end
