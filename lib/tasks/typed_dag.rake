namespace :typed_dag do
  desc "add the data into edges table for typed_dag"
  task backfill: :environment do
    # edgeレコードを全削除
    Edge.delete_all

    # ancestryを基にedgeレコードを追加
    Node.find_in_batches(batch_size: 1000) do |batch|
      batch.each do |n|
        next unless n.parent_id
        Edge.create_or_find_by!(from_id: n.parent_id, to_id: n.id, flow: 1)
      end
    end

    # 推移エッジの生成
    Node.rebuild_dag!

    # 例として一つrootノードを取り出し、子孫ノード数が一致するかを確認する。
    root = Node.roots.first
    if root
      dag = root.dag_descendants.count
      ancestry = root.descendants.count
      puts "dag_count=#{dag}, ancestry_count: #{ancestry}"
    else
      puts "no root found (ancestry)"
    end

    dag_root_count = Node.flow_roots.count
    ancestry_root_count = Node.roots.count

    # rootノードの数が一致するかを確認する。
    if dag_root_count
      puts "dag_root_count=#{dag_root_count}, ancestry_root_count: #{ancestry_root_count}"
    else
      puts "no root found (typed_dag)"
    end
  end
end
