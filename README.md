# hdmi_tx
 Pre release

## HDMI-TXコア
- 24bitカラー入力 (RGB888またはYCbCr444)
- 同期信号反転・非反転出力
- 色空間設定対応 (RGB/BT.601 YCbCr/BT.709 YCbCr/xvYCC.601/xvYCC.709)
- スキャンモード指定対応 (オーバースキャン/アンダースキャン)
- コンテンツモード指定対応 (Graphics/Photo/Cinema/Game)
- オーディオストリーム対応 (32KHz～192KHz,24bit 2chステレオ)
- DVIおよび最小HDMIエンコード対応
- コンパクトロジック (970LE+2M9k)
- 最大解像度HD720p (fmaxに依存)
- LVDSまたは疑似差動LVCMOS出力に対応
- インテルFPGA(MAX 10, Cyclone III, Cyclone IV, Cyclone V, Cyclone 10LP)、Gowin FPGA(GW1N, GW2A)に対応

## Video同期信号生成コア
- 任意の解像度のビデオ同期信号およびARIBライクなカラーバー信号を生成
- カラーバーはHDTV用(16:9)とSDTV用(4:3)のパターンを選択可能
- RGB(Full range)およびBT.601/BT.709のYCbCr(Limited range)を選択可能
- ビデオ信号用にVSYNC, HSYNC, CSYNC, V-Blank, H-Blank, Active信号を生成
- フレームバッファ制御用にframetop, linestart, pixelrequest信号を生成

# LICENSE

MIT License

__! NOTICE !__  
__This source does not include an HDMI license.__

- 本ソースコードにはHDMIのライセンスは含まれません。HDMI機器製品を開発・販売する際にはHDMI Licensing Administrator, Inc.のアダプターメンバーになる必要があります。
- 本ソースコードは研究・実験目的で開発されており、本ソースコードを直接あるいは間接的に利用したもので発生した全ての問題に対し、本ソースコードの製作者および権利者は一切の責務を負いません。
