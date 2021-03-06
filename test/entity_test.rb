require 'test_helper'

class EntityTest < Test::Unit::TestCase
  CONTEXTUAL_ID_PATTERN = /\A\#\h{8}\-\h{4}\-\h{4}\-\h{4}\-\h{12}\Z/ # UUID preceeded by #
  DATA_ID_PATTERN = /\A\h{8}\-\h{4}\-\h{4}\-\h{4}\-\h{12}\Z/ # UUID
  DIR_ID_PATTERN = /\A\h{8}\-\h{4}\-\h{4}\-\h{4}\-\h{12}\/\Z/ # UUID with trailing /

  test 'automatic ids' do
    crate = ROCrate::Crate.new

    assert_equal './', crate.id
    assert_equal 'ro-crate-metadata.jsonld', crate.metadata.id
    assert_match CONTEXTUAL_ID_PATTERN, ROCrate::Person.new(crate).id
    assert_match CONTEXTUAL_ID_PATTERN, ROCrate::Organization.new(crate).id
    assert_match CONTEXTUAL_ID_PATTERN, ROCrate::ContactPoint.new(crate).id
    assert_match DATA_ID_PATTERN, ROCrate::File.new(crate, StringIO.new('')).id
    assert_match DIR_ID_PATTERN, ROCrate::Directory.new(crate).id
  end

  test 'provided ids' do
    crate = ROCrate::Crate.new

    # Contextual entities need absolute URI or #bla ID
    assert_equal 'https://orcid.org/0000-0002-0048-3300',
                 ROCrate::Person.new(crate, 'https://orcid.org/0000-0002-0048-3300').id
    assert_equal '#finn', ROCrate::Person.new(crate, '#finn').id
    assert_equal '#finn', ROCrate::Person.new(crate, 'finn').id
    f = ROCrate::File.new(crate, StringIO.new(''), './hehe/').id
    refute f.end_with?('/')
    refute f.start_with?('.')
    refute f.start_with?('/')
    d = ROCrate::Directory.new(crate, fixture_file('directory'), 'test').id
    assert d.end_with?('/')
    refute d.start_with?('.')
    refute d.start_with?('/')
  end

  test 'fetch appropriate class for type' do
    assert_equal ROCrate::File, ROCrate::DataEntity.specialize('File')
    assert_equal ROCrate::File, ROCrate::DataEntity.specialize(['File', 'Image'])
    assert_equal ROCrate::File, ROCrate::DataEntity.specialize('SoftwareSourceCode')
    assert_equal ROCrate::File, ROCrate::DataEntity.specialize('anything that isnt a directory')
    assert_equal ROCrate::Directory, ROCrate::DataEntity.specialize('Dataset')
    assert_equal ROCrate::Directory, ROCrate::DataEntity.specialize(['Dataset', 'Image'])
    assert_equal ROCrate::File, ROCrate::DataEntity.specialize('Person')

    assert_equal ROCrate::Person, ROCrate::ContextualEntity.specialize('Person')
    assert_equal ROCrate::Person, ROCrate::ContextualEntity.specialize(['Person', 'Dave'])
    assert_equal ROCrate::ContactPoint, ROCrate::ContextualEntity.specialize('ContactPoint')
    assert_equal ROCrate::ContactPoint, ROCrate::ContextualEntity.specialize(['ContactPoint', 'Something'])
    assert_equal ROCrate::Organization, ROCrate::ContextualEntity.specialize('Organization')
    assert_equal ROCrate::Organization, ROCrate::ContextualEntity.specialize(['Organization', 'College'])
    assert_equal ROCrate::ContextualEntity, ROCrate::ContextualEntity.specialize('Something else')
    assert_equal ROCrate::ContextualEntity, ROCrate::ContextualEntity.specialize('File')
  end
end
