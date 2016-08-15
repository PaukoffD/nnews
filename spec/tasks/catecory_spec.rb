require 'rails_helper'

describe "Category tasks", :type => :task do

  context "count" do
   
    it "leaves unconfirmed subscriptions of age 3 days or younger" do
      not_overdue = create_list(:subscription, 2, confirmed: false, created_at: 3.days.ago)
      expect { invoke_task }.not_to change { Subscription.count }
    end

    it "deletes unconfirmed subscriptions of age more than 3 days" do
      overdue = create_list(:subscription, 2, confirmed: false, created_at: (3.days + 1.second).ago)
      expect { invoke_task }.to change { Subscription.count }.from(2).to(0)
    end

    it "ends gracefully when no subscriptions exist" do
      expect { invoke_task }.not_to raise_error
    end

    it "leaves confirmed subscriptions alone" do
      confirmed = create(:subscription, confirmed: true, created_at: 1.year.ago)
      expect { invoke_task }.not_to change { Subscription.count }
    end

    private

    def invoke_task
      task = Rake::Task["subscription:confirmation_overdue:delete"]
      # Ensure task is re-enabled, as rake tasks by default are disabled
      # after running once within a process http://pivotallabs.com/how-i-test-rake-tasks/
      task.reenable
      task.invoke
    end

  end

end