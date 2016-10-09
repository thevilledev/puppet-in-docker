node 'puppetclient' {
  $content = hiera('some_key')
  file { '/tmp/foo':
    content => $content
  }
}
