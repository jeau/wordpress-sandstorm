wordpress_repo = https://github.com/sandstormports/wordpress.git
wordpress_repo_branch = master
git_repo_dir = /home/vagrant


.PHONY: all clean

all: wordpress-read-only sandstorm/bin/getPublicId

clean:
	rm -rf wordpress-read-only

$(git_repo_dir)/wordpress/.git:
	sudo apt-get update
	sudo apt-get install -y git g++ automake libtool pkg-config curl \
		build-essential libcap-dev xz-utils zip \
		unzip strace clang discount python zlib1g-dev golang \
		cmake autoconf
	mkdir ~/go

	git clone ${wordpress_repo} $(git_repo_dir)/wordpress && cd $(git_repo_dir)/wordpress && git checkout ${wordpress_repo_branch}

wordpress-read-only: $(git_repo_dir)/wordpress/.git
	cp -r $(git_repo_dir)/wordpress wordpress-read-only
	rm -rf wordpress-read-only/.git
	cp wp-config.php wordpress-read-only/
	mv wordpress-read-only/wp-content wordpress-read-only/wp-content-read-only
	ln -s /var/wordpress/wp-content wordpress-read-only/wp-content
	cp read-only-plugins/sqlite-integration/db.php wordpress-read-only/wp-content-read-only/

sandstorm/bin/getPublicId: /usr/local/bin/capnp
	(cd sandstorm && make CXX=g++)

$(git_repo_dir)/capnproto/.git:
	git clone https://github.com/sandstorm-io/capnproto $(git_repo_dir)/capnproto

/usr/local/bin/capnp: $(git_repo_dir)/capnproto/.git
	(cd $(git_repo_dir)/capnproto/c++ && autoreconf -i && ./configure && make && sudo make install)
