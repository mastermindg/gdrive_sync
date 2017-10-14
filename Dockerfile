FROM hypriot/rpi-ruby

RUN apt-get update && apt-get install -qq -y \
	build-essential \
	patch \
	ruby-dev \
	zlib1g-dev \
	liblzma-dev \
	bash \
	cron \
 	vim \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /root
COPY Gemfile .
RUN bundle
ADD . .
RUN mkdir /files
VOLUME /files

CMD ruby /root/gdrive_sync.rb
