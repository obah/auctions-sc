import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NFT_ADDRESS = "0x3F684E473Fc5e9202aA642062B25d0002fFf5bAa";
const NFT_ID = 1;

const DutchAuctionModule = buildModule("DutchAuctionModule", (m) => {
  const nftAddress = m.getParameter("_nftAddress", NFT_ADDRESS);
  const nftId = m.getParameter("_nftId", NFT_ID);

  const dutchAuction = m.contract("DutchAuction", [nftAddress, nftId]);

  return { dutchAuction };
});

export default DutchAuctionModule;
