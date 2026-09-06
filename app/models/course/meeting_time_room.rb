# frozen_string_literal: true

# == Schema Information
#
# Table name: course_meeting_time_rooms
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  meeting_time_id :bigint           not null
#  room_id         :bigint           not null
#
# Indexes
#
#  index_course_meeting_time_rooms_on_meeting_time_id_and_room_id  (meeting_time_id,room_id) UNIQUE
#  index_course_meeting_time_rooms_on_room_id                      (room_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_time_id => course_meeting_times.id)
#  fk_rails_...  (room_id => rooms.id)
#
class Course::MeetingTimeRoom < ApplicationRecord
  self.table_name = "course_meeting_time_rooms"

  belongs_to :meeting_time, class_name: "Course::MeetingTime"
  belongs_to :room

  # A room change writes only to this join table, so the meeting time row itself
  # reports no change and its own callback stays quiet. Mark the enrolled users
  # here, or a section that moves rooms keeps the old location in Google Calendar.
  after_create :mark_enrolled_users_for_sync
  after_destroy :mark_enrolled_users_for_sync

  private

  def mark_enrolled_users_for_sync
    meeting_time&.mark_enrolled_users_for_sync
  end
end
