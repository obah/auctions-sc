import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NFT_ADDRESS = "0x3F684E473Fc5e9202aA642062B25d0002fFf5bAa";
const NFT_ID = 1;
const STARTING_BID: bigint = 2_500_000_000_000_000_000n;

const EnglishAuctionModule = buildModule("EnglishAuctionModule", (m) => {
  const nftAddress = m.getParameter("_nftAddress", NFT_ADDRESS);
  const nftId = m.getParameter("_nftId", NFT_ID);
  const startingBid = m.getParameter("_startingBid", STARTING_BID);

  const englishAuction = m.contract("EnglishAuction", [
    nftAddress,
    nftId,
    startingBid,
  ]);

  return { englishAuction };
});

export default EnglishAuctionModule;
