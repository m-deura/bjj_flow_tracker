namespace :guest do
  desc "古いゲストユーザーを削除"
  task cleanup: :environment do
    cutoff = 1.days.ago
    scope = User.where(provider: "guest").where("updated_at < ?", cutoff)

    deleted_user = 0
    scope.in_batches(of: 500) do |b|
      b.each do |user|
        user.destroy
        deleted_user += 1
      end
    end

    puts "[guest:cleanup] cutoff=#{cutoff} deleted_user=#{deleted_user}"
  end
end
