require 'test_helper'

class CrateTest < Test::Unit::TestCase

  def test_dereferencing
    crate = ROCrate::Crate.new
    info = crate.add_file(fixture_file('info.txt'), path: 'the_info.txt')
    more_info = crate.add_file(fixture_file('info.txt'), path: 'directory/more_info.txt')

    assert_equal crate, crate.dereference('./')
    assert_equal crate.metadata, crate.dereference('ro-crate-metadata.jsonld')
    assert_equal info, crate.dereference('./the_info.txt')
    assert_equal more_info, crate.dereference('./directory/more_info.txt')
    assert_nil crate.dereference('./directory/blabla.zip')
  end

  def test_dereferencing_equivalent_ids
    crate = ROCrate::Reader.read(fixture_file('workflow-0.2.0').path)
    workflow = crate.parts.first

    assert_equal crate, crate.dereference('./')
    assert_equal crate, crate.dereference('.')
    assert_equal crate.metadata, crate.dereference('ro-crate-metadata.jsonld')
    assert_equal crate.metadata, crate.dereference('./ro-crate-metadata.jsonld')
    assert_equal workflow, crate.dereference('./workflow/workflow.knime')
    assert_equal workflow, crate.dereference('workflow/workflow.knime')
  end

  def test_entity_equality
    crate = ROCrate::Crate.new
    entity = ROCrate::Entity.new(crate, 'id123')
    entity.properties['name'] = 'Jess'
    entity2 = ROCrate::Entity.new(crate, './id123')
    entity2.properties[ 'name'] = 'Fred'
    entity3 = ROCrate::Entity.new(crate, 'id123')
    entity3.properties['name'] = 'Hans'
    entity4 = ROCrate::Entity.new(crate, 'id456')
    entity4.properties['name'] = 'Hans'

    assert_equal entity.hash, entity2.hash
    assert_not_equal entity3.hash, entity4.hash
    assert_equal entity.absolute_id, entity2.absolute_id
    assert_not_equal entity.absolute_id, entity4.absolute_id
    assert_equal 1, ([entity] | [entity2]).length
    assert_equal 2, ([entity, entity4] | [entity2, entity4]).length
  end
end