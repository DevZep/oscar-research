module ClientNeedsAndProblems
  def client_needs_and_problems
    client_needs = []
    client_problems = []
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    org_short_names.each do |short_name|
      Organization.switch_to(short_name)
      client_needs.push(Need.all.reload)
      client_problems.push(Problem.all.reload)
    end
    Organization.switch_to('public')
    { client_needs: client_needs.flatten, client_problems: client_problems.flatten }
  end
end
