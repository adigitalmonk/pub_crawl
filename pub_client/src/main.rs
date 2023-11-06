use anyhow::Result;
use std::error::Error;
use std::io;
use tokio::io::Interest;
use tokio::net::TcpStream;

cola::make_conf! [
    "PUB_SERVER" => pub_server: String,
    "PUB_PORT" => pub_port: String
];


#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let conf = Configuration::default();
    let upstream_server = format!("{}:{}", conf.pub_server, conf.pub_port);
    let stream = TcpStream::connect(upstream_server).await?;
    println!("Connecting...");
    let mut sent = false;
    loop {
        let ready = stream.ready(Interest::READABLE | Interest::WRITABLE).await?;
        if ready.is_readable() {
            let mut data = vec![0; 1024];
            match stream.try_read(&mut data) {
                Ok(_) => {
                    println!("recv'd: {}", std::str::from_utf8(&data)?);
                    break;
                }
                Err(ref e) if e.kind() == io::ErrorKind::WouldBlock => {
                    continue;
                }
                Err(e) => {
                    return Err(e.into());
                }
            }
        }
        if !sent && ready.is_writable() {
            match stream.try_write(b"#peek test\n") {
                Ok(n) => {
                    println!("Sent {} bytes!", n);
                    sent = true;
                }
                Err(ref e) if e.kind() == io::ErrorKind::WouldBlock => {
                    continue;
                }
                Err(e) => {
                    return Err(e.into());
                }
            }
        }
    }
    Ok(())
}
