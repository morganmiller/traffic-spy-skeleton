class Source < ActiveRecord::Base
  validates :root_url, presence: true
  validates :identifier, uniqueness: true, presence: true

  has_many :payloads
  
  def user_agent_data
    payloads.pluck(:user_agent).map { |data| UserAgent.parse(data) }
  end
  
  def browser_info
    user_agent_data.inject({}) do |browsers, agent|
      if browsers.has_key?(agent.browser)
        browsers[agent.browser] += 1
      else
        browsers[agent.browser] = 1
      end
      browsers
    end
  end
  
  def platform_info
    user_agent_data.inject({}) do |platforms, agent|
      if platforms.has_key?(agent.platform)
        platforms[agent.platform] += 1
      else
        platforms[agent.platform] = 1
      end
      platforms
    end
  end
  
  def group_urls
    payloads.group(:url).count.sort_by { |k, v| v }.reverse
  end

  def average_times
    payloads.group(:url).average(:responded_in).sort_by { |k, v| v }.reverse
  end
  
  def events
    payloads.group(:event_name).count.sort_by {|k, v| -v}
  end
end
